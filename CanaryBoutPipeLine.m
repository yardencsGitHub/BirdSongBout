% pipeline for using new birdsong data for whatever purpose
% Start with a folder full of wav files
% Create file lists and spectrograms
% helper functions in
% '/Users/yardenc/Documents/GitHub/BirdSongBout/helpers'
% 1. CreateWavsList.m (requires setting the number of files to skip in
% parameter
% 2. CreateSpectrogramsFromWavs.m
%% 1: set folders dependencies
workDIR = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb11/llb11 WAV files';
%'/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018';
% '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb16/llb16 WAV files';
annotation_file = 'llb11_annotation_Mar_2019_Vika_4TF.mat';
%'llb3_annotation_Mar_2019_emily.mat';
template_file = 'llb11_templates_Mar_2019_Vika_4TF.mat';
%'llb3_templates_Mar_2019_emily.mat';
%llb16_templates_Alexa_Jan_2019_initial.mat';
estimates_file = 'Results_llb16_jan252019.mat';
%%
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');

%% 2: Create spectrograms from all WAV files
cd(workDIR);
CreateWavsList(workDIR,1);
CreateSpectrogramsFromWavs;
%% 3: add manual annotation and create training set

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
new_annotation_file = 'llb16_auto_annotation_Alexa_initial.mat';
save(fullfile(workDIR,new_annotation_file),'keys','elements');

%% 6: create single syllable snippet spectrograms
% To run classification tests and separation of syllable classes
% we create single snippets for each syllable
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');
path_to_annotation = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018/llb3_annotation_Mar_2019_emily.mat';
path_to_audio = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/Spring - AprMay2018';
path_to_target = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3/llb3_syllable_spects';
Prepare_individual_syllable_spects(path_to_annotation,path_to_audio,path_to_target);