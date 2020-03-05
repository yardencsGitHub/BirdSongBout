% pipeline for using new birdsong data for whatever purpose
% Start with a folder full of wav files
% Create file lists and spectrograms
% helper functions in
% '/Users/yardenc/Documents/GitHub/BirdSongBout/helpers'
% 1. CreateWavsList.m (requires setting the number of files to skip in
% parameter
% 2. CreateSpectrogramsFromWavs.m
%% 1: set folders dependencies
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb11/llb11 WAV files';
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018'; 
% workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb16/llb16 WAV files';
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019 - part 2';  %Haley's
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4444/lb4444 - Spring2019 - part 2'; %Vika
%workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1';
workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459';
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
annotation_file = 'rb4459_annotation_Aug_2019_Haley_4TF.mat';
%template_file = 'llb11_templates_Mar_2019_Vika_4TF.mat';
%template_file = 'llb3_templates_Apr_2019_emily.mat';
%'llb3_templates_Mar_2019_emily.mat';
%llb16_templates_Alexa_Jan_2019_initial.mat';
%template_file = 'llb16_templates_May_2019_alexa_4TF.mat';
%template_file = 'llb3_templates_June_2019_Haley.mat';
%template_file = 'lb4444_template_June_2019_Vika.mat';
%template_file = 'HandAnnotation_part1_lb4483_template.mat';
%template_file = 'rb4459_HandAnnotation_part1_template_Haley.mat';
template_file = 'rb4459_template_Aug_2019_Haley_4TF.mat';
estimates_file = 'Results_lb4483_Aug292019.mat';
estimates_file = 'Results_rb4459_Aug302019.mat';
disp('done names');
%%
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');

%% 2: Create spectrograms from all WAV files
cd(workDIR);
rmpath(genpath('/Users/yardenc/Documents/GitHub/VideoAnalysisPipeline/'))
startfrom = 1;
CreateWavsList(workDIR,1);
CreateSpectrogramsFromWavs;
disp('done creating spectrograms');


%% 3: add manual annotation and create training set
clc;
cd(workDIR);
add_annotation_to_mat(workDIR,annotation_file,template_file);
display('Done creating training set');
%% 4: now use the estimates to create the automatic annotation files
cd(workDIR);
path_annotation = fullfile(workDIR,annotation_file);
path_templates = fullfile(workDIR,template_file);
path_estimates = fullfile(workDIR,estimates_file);
[elements, keys] = update_annotation_from_ML_estimates(path_annotation,path_templates,path_estimates,'dt',0.002698412698413,'is_new',1);
disp('Done creating new elements');

%% 5: save new annotation file
new_annotation_file = 'rb4459_annotation_Sep_2019_Haley.mat';
save(fullfile(workDIR,new_annotation_file),'keys','elements');

%% 6: create single syllable snippet spectrograms
% To run classification tests and separation of syllable classes
% we create single snippets for each syllable
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');
%path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018/llb3_annotation_Mar_2019_emily.mat';
%path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019/llb3_annotation_May_2019_Haley.mat';
%path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1/HandAnnotation_part1_lb4483_Vika.mat';
path_to_annotation ='/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459/part 1/rb4459_HandAnnotation_part1_2019_Haley.mat';
%path_to_audio = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3 - Spring2019';
%path_to_audio = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1';
path_to_audio = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459/part 1';
%/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018';
%path_to_target = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring2019_syllable_snippets';
%path_to_target = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/SyllableSpects';
path_to_target = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459/SyllableSpects';
Prepare_individual_syllable_spects(path_to_annotation,path_to_audio,path_to_target);

%% check for outliers
% after running the python notebook
% FindOutliers
% Which is found in: /Users/yardenc/Documents/GitHub/BirdSongBout/helpers
% run Add_outliers_to_annotation.m
%orig_template = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/Part 1/HandAnnotation_part1_lb4483_template.mat';
orig_template = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459/part 1/rb4459_HandAnnotation_part1_template_Haley.mat';

%work_folder = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/lb4483/SyllableSpects';
work_folder = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/rb4459/SyllableSpects';
orig_annotation = path_to_annotation;
Add_outliers_to_annotation(work_folder, orig_annotation,orig_template)

