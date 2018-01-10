# A Matlab GUI for manual sound annotation and segmentation
This is an alpha version of a simple and keyboard-interface based tool for sound segmentation and annotation. I'm using it to create training sets for my [automated algorithm](https://github.com/yardencsGitHub/tf_syllable_segmentation_annotation), used in parsing canary song files.
## Running this tool
This tool runs on a single folder of WAV files that are sampled in the same rate. (Mine are sampled at 48000Hz). To run the GUI for the first time in a folder run the main matlab script **SingleSequenceManual(path_to_WAV_folder,'','')**. Set **path_to_WAV_folder** to be the full path to the folder that contains the WAV files.
During the first run you will name two files - the file that contains the annotations (annotation_file_name.mat) and the file that contains the syllable templates (template_file_name.mat). In future runs it is possible to choose those files by running **SingleSequenceManual(path_to_WAV_folder,'annotation_file_name.mat','template_file_name.mat')**.
## Workflow
Three panels open after running the GUI or after changing the WAV file (see below):
### Settings and parameters dialog
![DlgImage](https://github.com/yardencsGitHub/BirdSongBout/blob/master/helpers/GUI/img/DlgFig.png)
### Time window navigation
![MapImage](https://github.com/yardencsGitHub/BirdSongBout/blob/master/helpers/GUI/img/MapFig.png)
### Amplitude threshold 
![ThrImage](https://github.com/yardencsGitHub/BirdSongBout/blob/master/helpers/GUI/img/ThrFig.png)

![SpecImage](https://github.com/yardencsGitHub/BirdSongBout/blob/master/helpers/GUI/img/SpecFig.png)
