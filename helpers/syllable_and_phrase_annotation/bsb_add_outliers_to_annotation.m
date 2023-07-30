%%
% This script takes data structure of outliers matched to the structured
% created by 'Prepare_individual_syllable_spects.m' and created by
% 'FindOutliers.ipynb' (found in ../GitHub/BirdSongBout/helpers
% The script needs the matching annotation and template files and will
% create a new version of those with annotated outliers appended with '00'
function bsb_add_outliers_to_annotation(work_folder, orig_annotation,orig_template,varargin)
% Inputs:
%   work_folder - full path to folder that holds the results of the outlier
%       detector, containing annotation of outlier syllables as 'output' -
%       a vector of 1,-1
%   orig_annotation - string - full path to annotation file
%   orig_template -  string - full path to template file
% Parameters in string,value pairs
%   outlier_prefix - string - prefix of output files from outlier detector
%   spect_prefix - string - prefix of syllable snippet files
%% 
%work_folder = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring2019_syllable_snippets/';
%/Users/yardenc/Documents/Experiments/Behavior/Data/CanaryData/Chondroitinase/llb16/llb16_spects/';

%orig_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019/llb3_annotation_May_2019_Haley.mat';
%/Users/yardenc/Documents/Experiments/Behavior/Data/CanaryData/Chondroitinase/llb16/llb16_annotation_Alexa_initial.mat';
%orig_template = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019/llb3_templates_May_2019_Haley.mat';
%/Users/yardenc/Documents/Experiments/Behavior/Data/CanaryData/Chondroitinase/llb16/llb16_templates_Alexa_initial.mat';
cd(work_folder);
outlier_prefix = 'output_syllable_spects_';
spect_prefix = 'syllable_spects_';
nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
		case 'outlier_prefix'
			outlier_prefix=varargin{i+1};
        case 'spect_prefix'
			spect_prefix=varargin{i+1};
    end
end
disp('done');
%% fix templates
load(orig_template)
num_syls = numel(templates.wavs);
templates.wavs = [templates.wavs templates.wavs];
for cnt = num_syls+1:2*num_syls
    templates.wavs(cnt).segType = templates.wavs(cnt).segType*100;
end

[DIR,filename,ext]=fileparts(orig_template);
new_template_file = fullfile(DIR,['outliers_' filename ext]);
save(new_template_file,'templates');
disp('fixed new templates');
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

disp('fixed new annotation')

