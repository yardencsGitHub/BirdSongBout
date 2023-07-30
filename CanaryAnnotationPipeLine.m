function CanaryAnnotationPipeLine(path_to_parameters,steps_to_run)
% This is a pipeline for annotating new birdsong data using TweetyNet[1]
% and doing(/preparing for) some annotation cleanup.
% To work with this pipeline:
% - Start with a folder full of wav files that are all the songs recorded
% from a single bird.
% - Create a parameters file 
% 
% Inputs: 
%   path_to_parameters (string) 
%   steps_to_run: vector of integers - the steps to run

% The pipeline includes the steps:
% 1: Create spectrograms for all wav files
% 2: add manual annotation and create training set
% 3: use TweetyNet's estimates to create the automatic annotation files
% 4: create single syllable snippet spectrograms
% 5: check for outliers

% Several steps require manual work between them (annotated below)

% [1] 1. Cohen, Y. et al. Automated annotation of birdsong with a neural network that segments spectrograms. eLife 11, e63853 (2022).
%% prep: set folders dependencies
load(path_to_parameters);
workDIR = params.workDIR;
annotation_file = params.annotation_file;
new_annotation_file = params.new_annotation_file;
template_file = params.template_file;
estimates_file = params.estimates_file;
path_to_SyllableSpects = params.path_to_SyllableSpects;
GitHubDir = params.GitHubDir;
disp('done names');
%%
addpath(genpath(fullfile(GitHubDir,'BirdSongBout')),'-end');
%% 1: Create spectrograms from all WAV files in the working directory
if ismember(1,steps_to_run)
    cd(workDIR);
    rmpath(genpath(fullfile(GitHubDir,'VideoAnalysisPipeline/'))); % just to be sure
    startfrom = 1; % change this if you wish to ignore the first files in the list.
    wavs = bsb_create_wavs_list(workDIR,startfrom);
    params.wavs = wavs;
    save(path_to_parameters,'params');
    bsb_create_spectrograms_from_wavs(params);
    disp('done creating spectrograms');
end
%% 2: add manual annotation and create training set
% Before running this you need to annotate some songs and create an
% annotation file and a template file. Then, you update the parameters file
% and run this script again (no need to repeat the first step :)
if ismember(2,steps_to_run)
    clc;
    cd(workDIR);
    bsb_add_annotation_to_mat(workDIR,annotation_file,template_file);
    disp('Done creating training set');
end
%% 3: now use the estimates to create the automatic annotation files
% This step is now replaced by the vak python library
% (https://github.com/vocalpy/vak) that generates a .csv version of the
% annotation.
% Before running this part you need to use the annotated training set to
% create a TweetyNet model and use it to estimate labels in all the
% dataset.
if ismember(3,steps_to_run)
    cd(workDIR);
    [elements, keys] = update_annotation_from_ML_estimates(annotation_file,template_file,estimates_file,'dt',0.002698412698413,'is_new',1);
    disp('Done creating new elements');
end

% save new annotation file
save(new_annotation_file,'keys','elements');

%% 4: create single syllable snippet spectrograms
% To run classification tests and separation of syllable classes
% we create single snippets for each syllable.
% Before running this it is important to manually clean the annotations
if ismember(4,steps_to_run)
    Prepare_individual_syllable_spects(annotation_file,workDIR,path_to_SyllableSpects);
end

%% 5: check for outliers
% after running the python notebook in FindOutliers
% Which is found in: ... GitHub/BirdSongBout/helpers
% run Add_outliers_to_annotation.m

if ismember(5,steps_to_run)
    work_folder = path_to_SyllableSpects; 
    Add_outliers_to_annotation(work_folder,annotation_file,template_file)
end

