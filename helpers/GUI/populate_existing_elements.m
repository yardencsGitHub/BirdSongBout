function [keys, elements, templates] = populate_existing_elements(path_to_annotation_file,path_to_mat_files,path_to_wav_files,dt)
% This script takes an existing annotation file and updates or creates the tagging data from existing data.
% The annotation file must contain the varible 'keys' that holds all wav file names
% The annotation file must contain the structure 'elements' which holds an
% array of elements (e.g. 'base_struct' below):
%
% base_struct = struct('exper',exper, ...
%                              'filenum',sprintf('%04d',cnt), ...
%                              'segAbsStartTimes',[], ...
%                              'segFileStartTimes',[], ...
%                              'segFileEndTimes',[], ...
%                              'segType',[], ...
%                              'fs',48000, ...
%                              'drugstatus', 'No Drug', ...
%                              'directstatus', 'Undirected');
% 
% exper = struct('birdname',bird_exper_name,'expername','Recording from Canary',...
%             'desiredInSampRate',48000,'audioCh',0','sigCh',[],'datecreated',date,'researcher','... any name');
%
% Inputs: path_to_annotation_file - full or relative path including the
%                                   name of the files
%         path_to_mat_files - full or relative path to a directory that
%         holds .mat files corresponding to the same file names in 'keys'.
%         Each at file should have a vector of labeled time bins of
%         duration 'dt' (also an input).
%         path_to_wav_files - full or relative path
%
% Outputs: the updates elements as well as keys
%          'templates' a structure of template syllable samples

% dt = 1/3.692307692307692e+02;
MinSylDuration = 0.005;
include_zero = 0; % set to 1 to include '0' as a syllable type
flag = 1;
if ~exist(path_to_annotation_file)
    display(['No annotation file in path: ' path_to_annotation_file])
    flag = 0;
end
if ~exist(path_to_mat_files)
    display(['Invalid path to MAT files: ' path_to_mat_files])
    flag = 0;
end
if ~exist(path_to_wav_files)
    display(['Invalid path to WAV files: ' path_to_wav_files])
    flag = 0;
else
    d = dir(fullfile(path_to_wav_files,'*.wav'));
    [~,fs] = audioread(fullfile(path_to_wav_files,d(1).name));
end

if (flag == 1)
    clear templates;
    load(path_to_annotation_file);
    cd(path_to_mat_files);
    num_files = numel(keys);
    cnt = 1;
    syllables = [];
    for fnum = 1:num_files  
        fname = [keys{fnum}(1:end-3) 'mat'];
        load(fname,'labels');
        syllables = unique([syllables labels]);
    end
    if (include_zero == 0)
        syllables = setdiff(syllables,0);
    end
    for sln = 1:numel(syllables)
        templates.wavs(sln).filename = '';
        templates.wavs(sln).startTime = 0;
        templates.wavs(sln).endTime = 0;
        templates.wavs(sln).fs = fs;
        templates.wavs(sln).wav = [];
        templates.wavs(sln).segType = syllables(sln);
    end
    for fnum = 1:num_files  
        temp = regexp(keys{fnum},'_','split');
        fname = [keys{fnum}(1:end-3) 'mat'];
        load(fname,'labels');
        x = labels;
        x = [0 x 0];
        syl_onset = find(x(1:end-1) == 0 & x(2:end) ~=0);
        syl_offset = find(x(1:end-1) ~= 0 & x(2:end) ==0);
        if numel(syl_onset) > 0 % if we have any syllables at all
            
            time = getFileTime(keys{cnt});
            syl_durations = (syl_offset - syl_onset) * dt;
            % remove too short syllables <10mSec
            syl_onset(syl_durations < MinSylDuration) = [];
            syl_offset(syl_durations < MinSylDuration) = [];
            y = zeros(numel(syl_onset),1);
            for sylnum = 1:numel(y)
                y(sylnum) = mode(labels(syl_onset(sylnum):syl_offset(sylnum)-1));
                if isempty(templates.wavs(syllables(y(sylnum))).wav) 
                    templates.wavs(syllables(y(sylnum))).filename = keys{fnum};
                    templates.wavs(syllables(y(sylnum))).startTime = (syl_onset(sylnum) - 1) * dt;
                    templates.wavs(syllables(y(sylnum))).endTime = (syl_offset(sylnum) - 1) * dt;
                    [aud,fs] = audioread(fullfile(path_to_wav_files,keys{fnum}));
                    aud_time = [1/fs:1/fs:numel(aud)/fs] - 1/fs;
                    templates.wavs(syllables(y(sylnum))).wav = ...
                        aud((aud_time >= templates.wavs(syllables(y(sylnum))).startTime) & ...
                        (aud_time <= templates.wavs(syllables(y(sylnum))).endTime));
                end
            end
            temp_segType = syllables(y); 
            elements{cnt}.filenum = temp{2};
            elements{cnt}.segFileStartTimes = (syl_onset - 1) * dt;
            elements{cnt}.segAbsStartTimes = time + elements{cnt}.segFileStartTimes/(24*60*60);
            elements{cnt}.segFileEndTimes = (syl_offset - 1) * dt;
            elements{cnt}.segType = syllables(y)';
            cnt = cnt + 1;
        end
    end
        
end


    

  
