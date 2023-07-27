function [new_elements] = bsb_replace_annotated_entries(annotation_file,template_file,entry_file_list, DIR)
% Inputs:
% annotation_file, in the current directory or as a full path, is in the 
% Tweet format and contains 'elements' and 'keys'
% The fileds segAbsStartTimes, segFileStartTimes, segFileEndTimes, segType
% define the annotated segments in 'elements'
%
% template_file, in the current directory or as a full path, contains the
% Tweet syllable template structure 
%
% entry_file_list lives in DIR and contains a list of files, as a cell array with the same name, 
% that match a subset of the entries of the annotation file. 
% Each file in entry_file_list contains the variables t and labels (vectors) 
% that describe the annotation of each point in time.

% DIR specifies the full path to the new entry files.

% Outputs:
% The new elements and keys in Tweet format

if isempty(DIR) 
    DIR = pwd;
end


params = load(annotation_file);
new_elements = params.elements;
new_keys = params.keys;
clear params;
indx = [];
for cnt = 1:numel(new_keys)
    tokens = regexp(new_keys{cnt},'_','split');
    indx = [indx; str2num(tokens{2})];
end

load(template_file); 
syllables = [templates.wavs.segType];

load(fullfile(DIR,entry_file_list));

dt = 1/3.692307692307692e+02; %temporal resolution of spectrograms

num_files = numel(entry_file_list);
for fnum = 1:num_files   
    load(fullfile(DIR,[entry_file_list{fnum}(1:end-3) 'mat']));
    tokens = regexp(entry_file_list{fnum},'_','split');
    cnt = find(indx == str2num(tokens{2}));
    x = labels;
    x = [0 x 0];
    syl_onset = find(x(1:end-1) == 0 & x(2:end) ~=0);
    syl_offset = find(x(1:end-1) ~= 0 & x(2:end) ==0);
    if numel(syl_onset) > 0 % if we have any syllables at all
        time = getFileTime(new_keys{cnt});     
        y = zeros(numel(syl_onset),1);
        for sylnum = 1:numel(y)
            y(sylnum) = mode(labels(syl_onset(sylnum):syl_offset(sylnum)-1));
        end                            
        new_elements{cnt}.segFileStartTimes = (syl_onset - 1) * dt;
        new_elements{cnt}.segAbsStartTimes = time + new_elements{cnt}.segFileStartTimes/(24*60*60);
        new_elements{cnt}.segFileEndTimes = (syl_offset - 1) * dt;
        new_elements{cnt}.segType = syllables(y);
    end
    
end






