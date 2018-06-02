
addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/TimOs'));
% DIR = '/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav';
% annDIR = '/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav/annotated';
% auto_file = 'test_results_07_10_2017.mat';
% old_annotation_file = 'lrb85315auto_annotation3';
% template_file = 'lrb85315template.mat';
% corrections = 1; % a flag that indicates that we're going to reopen old annotations and replace some syllables' annotation
% syllables_to_reannotate = [300]; %  Theses syllables in the old files will trigger reannotation
new_files_list_file = 'FS_movies_list'; % contains the variables keys, noisefiles and songfiles 

cd(DIR);
load(new_files_list_file);
MinSylDuration = 0.005; % minimal syllable duration = 8 mSec
params = load(old_annotation_file);
old_songfiles = [];
old_songfiles_to_reannotate = [];
for fnum = 1:numel(params.keys)
    tokens = regexp(params.keys{fnum},'_','split');
    old_songfiles = [old_songfiles; str2num(tokens{2})];
    if any(ismember(unique(params.elements{fnum}.segType),syllables_to_reannotate)) && (corrections == 1)
        old_songfiles_to_reannotate = [old_songfiles_to_reannotate; str2num(tokens{2})];
    end
end
expr = params.elements{1}.exper;
base_struct = struct('exper',expr, ...
                     'filenum',0, ...
                     'segAbsStartTimes',[], ...
                     'segFileStartTimes',[], ...
                     'segFileEndTimes',[], ...
                     'segType',[], ...
                     'fs',48000, ...
                     'drugstatus', 'No Drug', ...
                     'directstatus', 'Undirected');
load(fullfile(annDIR,auto_file));
load(template_file);
syllables = [templates.wavs.segType];

num_files = numel(keys);
elements = {};
tempkeys = {};
dt = 1/3.692307692307692e+02;
% specific for this bird
% trill_syllables = [0:2 4 5 8 9 200 203 208 209 300:306 308 309];
cnt = 1;
for fnum = 1:num_files  
    temp = regexp(keys{fnum},'_','split');
    if (ismember(str2num(temp{2}),songfiles)) || (ismember(str2num(temp{2}),old_songfiles_to_reannotate))
        x = estimates{fnum};
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
                y(sylnum) = mode(estimates{fnum}(syl_onset(sylnum):syl_offset(sylnum)-1));
            end
            temp_segType = syllables(y); 
            flags = zeros(size(temp_segType));
            % Deal with lonely syllables # 4,5,.. that are never alone
            for loc = 1:numel(syl_onset)
                if ismember(temp_segType(loc),trill_syllables) & (numel(syl_onset) > 1)
                    if (loc == 1)
                        if temp_segType(2) ~= temp_segType(1)
                            flags(loc) = 1;
                        end
                    elseif (loc == numel(syl_onset))
                        if temp_segType(end) ~= temp_segType(end-1)
                            flags(loc) = 1;
                        end
                    else
                        if (temp_segType(loc) ~= temp_segType(loc-1)) & (temp_segType(loc) ~= temp_segType(loc+1))
                            flags(loc) = 1;
                        end
                    end
                end
            end                 
            
            if ismember(str2num(temp{2}),old_songfiles_to_reannotate)
                old_loc = find(old_songfiles == str2num(temp{2}));
                params.elements{old_loc}.segFileStartTimes = (syl_onset - 1) * dt;
                params.elements{old_loc}.segAbsStartTimes = time + params.elements{old_loc}.segFileStartTimes/(24*60*60);
                params.elements{old_loc}.segFileEndTimes = (syl_offset - 1) * dt;


                params.elements{old_loc}.segType = syllables(y)';

                %params.elements{old_loc}.segType = syllables(y);

                params.elements{old_loc}.segType(flags == 1) = -1;
            else
                elements{cnt} = base_struct;

                elements{cnt}.filenum = temp{2};
                elements{cnt}.segFileStartTimes = (syl_onset - 1) * dt;
                elements{cnt}.segAbsStartTimes = time + elements{cnt}.segFileStartTimes/(24*60*60);
                elements{cnt}.segFileEndTimes = (syl_offset - 1) * dt;


                elements{cnt}.segType = syllables(y)';

               % elements{cnt}.segType = syllables(y);

                elements{cnt}.segType(flags == 1) = -1;
                tempkeys{cnt} = [keys{fnum}(1:end-3) 'wav'];
                cnt = cnt + 1;
            end
        end
    end
    
end
    
    
    