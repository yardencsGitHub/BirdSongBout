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
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');

%% 2: Create spectrograms from all WAV files
cd(workDIR);
CreateWavsList(workDIR,1);
CreateSpectrogramsFromWavs;
%% 3: add manual annotation and create training set
annotation_file = 
template_file
add_annotation_to_mat(workDIR,annotation_file,template_file);
%%
cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_6');
path_to_annotation_file = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_6/bird6_annotation.mat';
path_to_mat_files = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_6/mat';
path_to_wav_files = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_6';
[keys, elements, templates] = create_empty_elements(pwd,'bird6',[]);
save bird6_annotation keys elements;
save bird6_templates templates;
dt = 1/3.692307692307692e+02;
[keys, elements, templates] = populate_existing_elements(path_to_annotation_file,path_to_mat_files,path_to_wav_files,dt);
cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_6');
save bird6_annotation keys elements;
save bird6_templates templates;
%% now after the manual fix (by Emily M). Create annotated data

add_annotation_to_mat('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_2','bird2_annotation_emily.mat','bird2_templates_emily.mat');
