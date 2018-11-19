% pipeline for using Jeff's data
% helper functions in
% '/Users/yardenc/Documents/GitHub/BirdSongBout/helpers'
% 1. NameAndMoveFiles.m
% 2. segment_labels_from_phrase_annotations.m
% 3.  In the wav file directory: [keys, elements, templates] = create_empty_elements(DIR,bird_exper_name,[])
% 4. [keys, elements, templates] = populate_existing_elements(path_to_annotation_file,path_to_mat_files,path_to_wav_files,dt)
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
