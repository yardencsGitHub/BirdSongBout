function varargout = ParamsDialog(varargin)
% PARAMSDIALOG MATLAB code for ParamsDialog.fig
%      PARAMSDIALOG, by itself, creates a new PARAMSDIALOG or raises the existing
%      singleton*.
%
%      H = PARAMSDIALOG returns the handle to a new PARAMSDIALOG or the handle to
%      the existing singleton*.
%
%      PARAMSDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMSDIALOG.M with the given input arguments.
%
%      PARAMSDIALOG('Property','Value',...) creates a new PARAMSDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ParamsDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ParamsDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ParamsDialog

% Last Modified by GUIDE v2.5 02-Oct-2018 15:38:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParamsDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @ParamsDialog_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ParamsDialog is made visible.
function ParamsDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParamsDialog (see VARARGIN)

% Choose default command line output for ParamsDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'UserData',handles);
% UIWAIT makes ParamsDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ParamsDialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in SylTags.
function SylTags_Callback(hObject, eventdata, handles)
% hObject    handle to SylTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SylTags contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SylTags


% --- Executes during object creation, after setting all properties.
function SylTags_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SylTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StepSize_Callback(hObject, eventdata, handles)
% hObject    handle to StepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StepSize as text
%        str2double(get(hObject,'String')) returns contents of StepSize as a double


% --- Executes during object creation, after setting all properties.
function StepSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinSyl_Callback(hObject, eventdata, handles)
% hObject    handle to MinSyl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinSyl as text
%        str2double(get(hObject,'String')) returns contents of MinSyl as a double


% --- Executes during object creation, after setting all properties.
function MinSyl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinSyl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinGap_Callback(hObject, eventdata, handles)
% hObject    handle to MinGap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinGap as text
%        str2double(get(hObject,'String')) returns contents of MinGap as a double


% --- Executes during object creation, after setting all properties.
function MinGap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinGap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddTag.
function AddTag_Callback(hObject, eventdata, handles)
% hObject    handle to AddTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
taglist = cellfun(@str2num,handles.SylTags.String);
newtag = str2num(handles.NewTag.String);
if ~ismember(newtag,taglist)
    if ismember(-1,taglist)      
        handles.SylTags.String(numel(handles.SylTags.String)) = {num2str(newtag)};
        handles.SylTags.String(numel(handles.SylTags.String)+1) = {num2str(-1)};
    else
        handles.SylTags.String(numel(handles.SylTags.String)+1) = {num2str(newtag)};
    end
    templates = handles.show_button.UserData;
    newt.filename = '';
    newt.startTime = 0;
    newt.endTime = 0;
    newt.fs = 0;
    newt.wav = [];
    newt.segType = newtag;
    templates.wavs = [templates.wavs newt];
end
handles.show_button.UserData = templates;
%new



function NewTag_Callback(hObject, eventdata, handles)
% hObject    handle to NewTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewTag as text
%        str2double(get(hObject,'String')) returns contents of NewTag as a double


% --- Executes during object creation, after setting all properties.
function NewTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function caxis_min_Callback(hObject, eventdata, handles)
% hObject    handle to caxis_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of caxis_min as text
%        str2double(get(hObject,'String')) returns contents of caxis_min as a double


% --- Executes during object creation, after setting all properties.
function caxis_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to caxis_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function caxis_max_Callback(hObject, eventdata, handles)
% hObject    handle to caxis_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of caxis_max as text
%        str2double(get(hObject,'String')) returns contents of caxis_max as a double


% --- Executes during object creation, after setting all properties.
function caxis_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to caxis_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in file_list.
function file_list_Callback(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_list
pre = '<HTML><FONT color="'; post = '</FONT></HTML>';
elements = handles.file_list.UserData;
taglist = cellfun(@str2num,handles.SylTags.String);
colors = distinguishable_colors(numel(taglist),'w');
current_tags = unique(elements{handles.file_list.Value}.segType);
tagtext = {};
for tagnum = 1:numel(current_tags)
    tagtext{tagnum} = [pre rgb2hex(255*colors(find(taglist == current_tags(tagnum)),:)) ...
        '">' num2str(current_tags(tagnum)) post]; 
end
handles.existing_labels.Value = 1;
handles.existing_labels.String = tagtext;

% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in show_button.
function show_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fmin = 300; fmax = 8000;
fmin = handles.save_settings.UserData{1}.fmin;
fmax = handles.save_settings.UserData{1}.fmax;
templates = handles.show_button.UserData;
sylnum = handles.SylTags.Value;
dt = 0.9167*0.001;
FS = templates.wavs(sylnum).fs;
fbins = 257;
sig = templates.wavs(sylnum).wav;        
[S,F,T,P] = spectrogram((sig/(sqrt(mean(sig.^2)))),220,220-44,512,FS,'reassigned');
sig_len = size(S,2);
figure; imagesc(T,F,log(1+abs(S))); colormap(1-gray); set(gca,'Ydir','normal'); ylim([fmin fmax]); caxis([str2num(handles.caxis_min.String) str2num(handles.caxis_max.String)]); set(gca,'FontSize',16); 
title(['Syllable ' num2str(templates.wavs(sylnum).segType) , ', file: ' templates.wavs(sylnum).filename],'interpreter','none');
xticks([T(1) T(end)]-T(1)); xlabel('Time(sec)'); ylabel('Frequency(Hz)');

% --- Executes on button press in save_settings.
function save_settings_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings_params = handles.save_settings.UserData{1};
window_handles = handles.save_settings.UserData{2};
settings_params.window_positions = [window_handles{1}.figure1.Position;get(window_handles{2},'Position');get(window_handles{3},'Position');get(window_handles{4},'Position')];
save(handles.save_settings.UserData{3},'settings_params');



    


% --- Executes on key press with focus on file_list and none of its controls.
function file_list_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
pre = '<HTML><FONT color="'; post = '</FONT></HTML>';
elements = handles.file_list.UserData;
taglist = cellfun(@str2num,handles.SylTags.String);
colors = distinguishable_colors(numel(taglist),'w');
current_tags = unique(elements{handles.file_list.Value}.segType);
tagtext = {};
for tagnum = 1:numel(current_tags)
    tagtext{tagnum} = [pre rgb2hex(255*colors(find(taglist == current_tags(tagnum)),:)) ...
        '">' num2str(current_tags(tagnum)) post]; 
end
handles.existing_labels.String = tagtext;


% --- Executes on selection change in existing_labels.
function existing_labels_Callback(hObject, eventdata, handles)
% hObject    handle to existing_labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns existing_labels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from existing_labels


% --- Executes during object creation, after setting all properties.
function existing_labels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to existing_labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

        


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over file_list.
function file_list_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pre = '<HTML><FONT color="'; post = '</FONT></HTML>';
elements = handles.file_list.UserData;
taglist = cellfun(@str2num,handles.SylTags.String);
colors = distinguishable_colors(numel(taglist),'w');
current_tags = unique(elements{handles.file_list.Value}.segType);
tagtext = {};
for tagnum = 1:numel(current_tags)
    tagtext{tagnum} = [pre rgb2hex(255*colors(find(taglist == current_tags(tagnum)),:)) ...
        '">' num2str(current_tags(tagnum)) post]; 
end
handles.existing_labels.String = tagtext;


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
message = sprintf(['This GUI is operated by keyboard shortcuts. All shortcuts are executed as callbacks of the spectrogram window so if something doesn''t work it may be because the key was pressed while another window was selected\n' ...
    '\nWhen the GUI starts or when a new file is processed the spectrogram window is absent. Set the threshold in the amplitude window and press ENTER\n' ...
    '\nKeyboard Commands:\n' ...
    'z,x - scroll left or right' ...
    '\nu - update parameters if they were changed in the parameters window. Update threshold or time window if they were changed, recalculate threshold boundaries (green and red lines)' ...
    '\ne - erase file entry (not the file). Currently this is irreversible and a prompt will pop up' ...
    '\nr - update colors in threshold and time window panels' ...
    '\nt - apply tag to selected syllable .. as chosen in the parameters window' ...
    '\np - play current segment' ...
    '\ns - select segment on the spectrogram window in which all syllables will receive the selected label' ...
    '\nd - delete selected syllable' ...
    '\nf - select a segment in the spectrogram to focus on' ...
    '\ng - move all visible syllable edges to nearest threshold crossing (same as double clicking all syllables) if no overlaps occur' ...
    '\nj - join the current selected syllable with the next and apply the selected syllable''s tag' ...
    '\nb - create new syllables at the current threshold boundaries (green and red lines) and give them the selected tag' ...
    '\nn - save and open the next file entry (or the selected entry if it''s not the next in the list)' ...
    '\nq - quit']);
msgbox(message,'HELP')


% --- Executes on button press in delete_tag_button.
function delete_tag_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_tag_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.delete_tag_button.UserData = 0;
templates = handles.show_button.UserData;
taglist = cellfun(@str2num,handles.SylTags.String);
segnumbers = [templates.wavs.segType];
[indx,okres] = listdlg('ListString',{num2str(reshape(segnumbers,numel(segnumbers),1))},'Name','Which labels would you like to join?');
if numel(indx) > 1 & (okres ~= 0)
    strres = questdlg(['Are you sure that you want to join labels ' num2str(segnumbers(indx)) ' ?']);
    if strcmp(strres,'Yes')
        tmpp = msgbox('The annotation and template files are about to irreversibly change. Make a backup copy!'); uiwait(tmpp);
        handles.delete_tag_button.UserData = 1;
        minval = min(segnumbers(indx));
        locs_in_templates = find(ismember(segnumbers,segnumbers(indx)));
        locs_in_taglist = find(ismember(taglist,segnumbers(indx)));
        % update tag list
        if ismember(-1,taglist) 
            taglist = [1:(numel(taglist)-numel(indx)) -1]; 
            tempcell = cell(numel(taglist),1);
            for tmpcnt = 1:numel(tempcell)
                tempcell{tmpcnt} = num2str(taglist(tmpcnt));
            end
        else
            taglist = [1:(numel(taglist)-numel(indx)+1) -1]; 
            tempcell = cell(numel(taglist),1);
            for tmpcnt = 1:numel(tempcell)
                tempcell{tmpcnt} = num2str(taglist(tmpcnt));
            end
        end
        handles.SylTags.String = tempcell;
        % update templates
        
        templates.wavs(indx(2:end)) = [];
        for tmpcnt = 1:numel(templates.wavs)
            templates.wavs(tmpcnt).segType = tmpcnt;
        end
        handles.show_button.UserData = templates;
        % update elements
        new_segnumbers = segnumbers;
        
        new_segnumbers(indx) = indx(1);
        new_segnumbers(~ismember(1:numel(new_segnumbers),indx)) = [1:(indx(1)-1) (indx(1)+1):(numel(segnumbers)-numel(indx)+1)];
        
        elements = handles.file_list.UserData;
        ftmp = waitbar(0,'updating elements');
        for fnumtmp = 1:numel(elements)
            waitbar(fnumtmp/numel(elements),ftmp);
            for segcnt = 1:numel(elements{fnumtmp}.segType)
                tmploc = find(segnumbers == elements{fnumtmp}.segType(segcnt));
                if ~isempty(tmploc)
                    elements{fnumtmp}.segType(segcnt) = new_segnumbers(tmploc);
                end
            end
        end
        handles.file_list.UserData = elements;
        tmpp = msgbox('Done! Update the main window immediately!'); 
        close(ftmp);
    end

end



function freq_min_Callback(hObject, eventdata, handles)
% hObject    handle to freq_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_min as text
%        str2double(get(hObject,'String')) returns contents of freq_min as a double


% --- Executes during object creation, after setting all properties.
function freq_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freq_max_Callback(hObject, eventdata, handles)
% hObject    handle to freq_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq_max as text
%        str2double(get(hObject,'String')) returns contents of freq_max as a double


% --- Executes during object creation, after setting all properties.
function freq_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in choose_template.
function choose_template_Callback(hObject, eventdata, handles)
% hObject    handle to choose_template (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in choose_annotation.
function choose_annotation_Callback(hObject, eventdata, handles)
% hObject    handle to choose_annotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function dir_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dir_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in choose_dir.
function choose_dir_Callback(hObject, eventdata, handles)
% hObject    handle to choose_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmpDIR = uigetdir(pwd,'Choose a directory that has all wav files and annotation files');
%cd(tmpDIR);
new_ann = questdlg('Do you want to start a new annotation file?','Annotation','YES','NO','NO');
if strcmp(new_ann,'NO')
    [tmp_ann_fname, ~, ~] = uigetfile(fullfile(tmpDIR,'*.mat'), 'Choose an ANNOTATION file');
    [tmp_tmp_fname, ~, ~] = uigetfile(fullfile(tmpDIR,'*.mat'), 'Choose a TEMPLATE file');
else
    tmp_ann_fname = 'nofile.mat'; tmp_tmp_fname = 'nofile.mat';
end
handles.dir_name.UserData = 1;
handles.dir_name.String = tmpDIR;
handles.annotation_filename.String = tmp_ann_fname;
handles.templates_filename.String = tmp_tmp_fname;
handles.choose_dir.UserData = {tmpDIR tmp_ann_fname tmp_tmp_fname};
handles.choose_dir.Enable = 'off'; 
uiresume(handles.figure1);
 
