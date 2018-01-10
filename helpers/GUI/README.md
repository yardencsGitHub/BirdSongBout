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
Set the threshold by dragging the line up and down and then press ENTER. A new panel will appear:
### The spectrogram window
![SpecImage](https://github.com/yardencsGitHub/BirdSongBout/blob/master/helpers/GUI/img/SpecFig.png)
This panel is the main focus in working on each file and all keyboard hotkeys, listed below, function only when this panel is selected.
Importantly, changes to settings in other windows will only take an effect when updating the main (spectrogram) panel (by selecting it and pressing 'u', see below)
### Hotkeys
* u
* z,x
* e
* r
* t
* p
* s
* d
* f
* g
* j
* b
* n
* q

