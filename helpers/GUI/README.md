# A Matlab GUI for manual sound annotation and segmentation
This is an alpha version of a simple and keyboard-interface based tool for sound segmentation and annotation. I'm using it to create training sets for my [automated algorithm](https://github.com/yardencsGitHub/tf_syllable_segmentation_annotation), used in parsing canary song files.
## Running this tool
This tool runs on a single folder of WAV files that are sampled at the same rate. (Mine are sampled at 48000Hz). To run the GUI for the first time in a folder run the main matlab script **SingleSequenceManual(path_to_WAV_folder,'','')**. Set **path_to_WAV_folder** to be the full path to the folder that contains the WAV files.
During the first run you will name two files - the file that contains the annotations (annotation_file_name.mat) and the file that contains the syllable templates (template_file_name.mat). In future runs it is possible to choose those files by running **SingleSequenceManual(path_to_WAV_folder,'annotation_file_name.mat','template_file_name.mat')**.
## Workflow
Three panels open after running the GUI or after starting to work on a new WAV file (see below):
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
* **u** - Update - all changes in the Settings, Time window, and Amplitude threshold panels will take place by pressing this hotkey in the main (Spectrogram) panel. For example, after moving the threshold the crossing points, marked by green and red lines (threshold crossing onset and offset) will move after updating.
* **z,x** - Shift time axis left (z) and right (x). The threshold crossing points need to be recalculated (press 'u') 
* **e** - Erase the current file - A Yes / No prompt will confirm that the current file (The one whose spectrogram is being worked on .. not the one highlighted in the settings dialog). Pressing Yes will remove the entry from the annotation file and the next entryu will be loaded. This is irreversible.
* **r** - Update maps - This updates the colors in the threshold and time window panels. Not really useful, but nice to have.
* **t** - Tag current selected segment - The tag, chosen in the settings panel will be applied to the currently selected segment. This will have no effect if the selected segment is outside the currently visible time window (in the spectrogram panel)
* **p** - Play currently visible spectrogram.
* **s** - Tag a flexible segment - This is very useful. The mouse is used to choose a time segment in the Spectrogram panel and all segments in the chosen range get the tag that is currently chosen in the setting window.
* **a** - Add segment - A new segment will be created in the range, chosen by clicking and dragging the mouse. The new segment cannot overlap with others and will get the tag **'-1'** that indicates an un-annotated segment. 
* **d** - Delete a segment - The currently chosen segment will be deleted if it's visible
* **f** - Focus - Indicate a range in the spectrogram and zoom.
* **g** - Move all segment bounaries to the nearest threshold crossing. This command is processed from left (earlier) to right (later) in the Spectrogram panel. Boundaries will not move if overlaps occur or if the threshold crossings are outside the visible time range.
* **j** - Join - The currently chosen segment, if visible, is joined with the next. The tag of the currently chosen segment is applied to the joined segment.
* **b** - Create new segments. The segments will be created, left to right, at the threshold crossing boundaries in the visible time window. The new segments will get the label that is chosen in the settings window.
* **l** - Label - This updates the sample of the currently chosen tag. The currently chosen segment will be saved in the templates file only if it has the same tag as the currently chosen tag in the settings panel.
* **n** - New entry - Changes will be saved and either the next entry will be opened or the entry, chosen in the settings panel.
* **q** - Quit - A Yes / No prompt allows choosing to save entries and settings before closing all windows.
### Mouse operations
Some operations are done with the mouse:
* **Selecting a segment** - Clicking on a segment in the spectrogram panel will *Select* it. The rectangle that marks the segment will change to an active rectangle.
* **Changing segment boundaries** - When a segment is selected, the entire segment and its boundaries can be dragged. This allows small corrections. **WARNING!** This also allows dragging the segment to an illegal position (e.g. make it overlap with other segments). This may be fixed in the future.
* **Set segment boundaries to nearest threshold crossings** - Double-Click a segment to do that.
* **Change threshold and time range** - The threshold line (in the Treshold panel) and the time window (in its panel) can be dragged and reshaped with the mouse. These changes will take an effect after updating the main (Spectrogram) window (by pressing 'u')
### Settings
The following can be done in the Settings and parameters panel:
* **Select an entry** - Selecting an entry in the in the left box will show the tags that exist in that entry as colored numbers in the neighboring box.
* **Select a tag** - Picking a tag in the 'Tags' box will allow applying it in the Spectrogram.
* **The Delete! button** - *Under construction* - This will allow deleting a tag and changing all its occurances to '-1'.
* **The Show button** - This shows the saved sample of the currently chosen tag. The figure is **not** scaled.
* **The Add: button** - This will create a new tag. The tags **must** be numbers. Enter a number in the space next to the button before pressing it.
* **save settings** - This saves the settings file. This file, and the locations of the windows, are also saved when switching entries.
* **Parameters:**
  * Step - The time jump in pressing 'z' or 'x' in the Spectrogram windows
  * Min Gap, Min Syl - These set the minimal gap between syllables and the minimal syllable durations. These parameters affect the threshold crossing boundaries and will update upter pressing 'u' in the Spectrogram panel.
  * CAXIS - sets the color axis in the spectrogram window. Updates after pressing 'u'.

