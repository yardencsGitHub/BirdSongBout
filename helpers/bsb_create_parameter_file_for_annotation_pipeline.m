function params = bsb_create_parameter_file_for_annotation_pipeline(target_file,varargin)
% Yarden 2022
% This function creates a .mat file with all the parameters needed to run
% the script ../GitHub/BirdSongBout/CanaryBoutPipeLine.m
% Input:
%   target_file (string): the full path to the file to be created
% Output:
%   params (struct): all the parameters as saved

is_new = 1;
nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
        case 'is_new'
			is_new = varargin{i+1};
    end
end

if is_new == 0
    load(target_file,'params');
end

params.GitHubDir = '/Users/yardenc/Documents/GitHub';
params.workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459';
params.annotation_file = '/Users/yardenc/Dropbox (Weizmann Institute)/Datasets/Cohen_CanarySongs/rb4459/rb4459_annotation_Aug_2019_Haley_4TF.mat';
params.template_file = '/Users/yardenc/Dropbox (Weizmann Institute)/Datasets/Cohen_CanarySongs/rb4459/rb4459_template_Aug_2019_Haley_4TF.mat';
params.estimates_file = '/Users/yardenc/Dropbox (Weizmann Institute)/Datasets/Cohen_CanarySongs/rb4459/Results_rb4459_Aug302019.mat';
params.new_annotation_file = '/Users/yardenc/Dropbox (Weizmann Institute)/Datasets/Cohen_CanarySongs/rb4459/rb4459_annotation_Sep_2019_Haley.mat';
params.path_to_SyllableSpects = '';
save(target_file,'params');



%%%%%%%%%%%% Legacy parameters:
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb11/llb11 WAV files';
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018'; 
% workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb16/llb16 WAV files';
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019 - part 2';  %Haley's
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4444/lb4444 - Spring2019 - part 2'; %Vika
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1';
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459';
%annotation_file = 'llb11_annotation_Apr_2019_Vika_4TF.mat';
%annotation_file = 'llb3_annotation_Apr_2019_emily_4TF.mat';
%'llb3_annotation_Mar_2019_emily.mat';
%annotation_file = 'llb16_annotation_May_2019_alexa_4TF.mat';
%annotation_file = 'refined_outliers_llb3_annotation_May_2019_Haley.mat';
%annotation_file = 'llb3_annotation_May_2019_Haley_4TF.mat';
%annotation_file = 'llb3_1_annotation_July_2019_Haley_4TF.mat';
%annotation_file = 'lb4444_annotation_June_2019_Vika.mat';
%annotation_file = 'HandAnnotation_part1_lb4483_Vika.mat';
%annotation_file = 'rb4459_HandAnnotation_part1_2019_Haley.mat';
%annotation_file = 'rb4459_annotation_Aug_2019_Haley_4TF.mat';
%template_file = 'llb11_templates_Mar_2019_Vika_4TF.mat';
%template_file = 'llb3_templates_Apr_2019_emily.mat';
%'llb3_templates_Mar_2019_emily.mat';
%llb16_templates_Alexa_Jan_2019_initial.mat';
%template_file = 'llb16_templates_May_2019_alexa_4TF.mat';
%template_file = 'llb3_templates_June_2019_Haley.mat';
%template_file = 'lb4444_template_June_2019_Vika.mat';
%template_file = 'HandAnnotation_part1_lb4483_template.mat';
%template_file = 'rb4459_HandAnnotation_part1_template_Haley.mat';
%template_file = 'rb4459_template_Aug_2019_Haley_4TF.mat';
%estimates_file = 'Results_rb4459_Aug302019.mat';

%addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');
%path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018/llb3_annotation_Mar_2019_emily.mat';
%path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019/llb3_annotation_May_2019_Haley.mat';
%path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1/HandAnnotation_part1_lb4483_Vika.mat';
%path_to_annotation ='/Users/yardenc/Dropbox/Cohen_CanaryBoutAnnotation/lb4483/Part 1/part1_lb4483_annotation_Feb_2020_Vika.mat';
%path_to_audio = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019';
%path_to_audio = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1';
%path_to_audio = '/Users/yardenc/Dropbox/Cohen_CanaryBoutAnnotation/lb4483/Part 1';
%/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018';
%path_to_target = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring2019_syllable_snippets';
%path_to_target = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/SyllableSpects';

%orig_template = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1/HandAnnotation_part1_lb4483_template.mat';
% orig_template = '/Users/yardenc/Dropbox/Cohen_CanaryBoutAnnotation/lb4483/Part 1/part1_lb4483_template_Feb_2020.mat';
%'/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459/part 1/rb4459_HandAnnotation_part1_template_Haley.mat';

%work_folder = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/SyllableSpects';
%path_to_SyllableSpects = '/Users/yardenc/Dropbox/Cohen_CanaryBoutAnnotation/lb4483/Part 1/SyllableSpects';