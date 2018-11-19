%%
% This script takes data structure of outliers matched to the structured
% created by 'Prepare_individual_syllable_spects.m' and created by
% 'FindOutliers.ipynb'
% The script needs the matching annotation and template files and will
% create a ne version of those with annotated outliers appended with '00'

%% 
work_folder = '/Users/yardenc/Documents/Experiments/Behavior/Data/CanaryData/Chondroitinase/llb11/Individual syllable spects/';
orig_annotation = '/Users/yardenc/Documents/Experiments/Behavior/Data/CanaryData/Chondroitinase/llb11/llb11_annotation_Vika_initial_part_1.mat';
orig_template = '/Users/yardenc/Documents/Experiments/Behavior/Data/CanaryData/Chondroitinase/llb11/llb11_templates_Vika_initial.mat';
cd(work_folder);
outlier_prefix = 'output_syllable_spects_';
spect_prefix = 'syllable_spects_';
num_syls = 29;
%% fix templates
load(orig_template)
templates.wavs = [templates.wavs templates.wavs];
for cnt = num_syls+1:2*num_syls
    templates.wavs(cnt).segType = templates.wavs(cnt).segType*100;
end

[DIR,filename,ext]=fileparts(orig_template);
new_template_file = fullfile(DIR,['outliers_' filename ext]);
save(new_template_file,'templates');
%% fix annotation
load(orig_annotation);
for cnt = 1:num_syls
    load([spect_prefix num2str(cnt) '.mat']);
    load([outlier_prefix num2str(cnt) '.mat'])
    locs = find(output == -1);
    for segnum = 1:numel(locs) %size(syllable_spects.idx,1)
        
        fnum = syllable_spects.idx(locs(segnum),1);
        loc = syllable_spects.idx(locs(segnum),2);
        elements{fnum}.segType(loc) = elements{fnum}.segType(loc)*100;
    end
end

[DIR,filename,ext]=fileparts(orig_annotation);
new_annotation_file = fullfile(DIR,['outliers_' filename ext]);
save(new_annotation_file,'keys','elements');

disp('done')

