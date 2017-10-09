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

% Last Modified by GUIDE v2.5 06-Oct-2017 12:06:37

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
newtag = str2num(handles.NewTag.String{:});
if ~ismember(newtag,taglist)
    handles.SylTags.String(numel(handles.SylTags.String)+1) = {num2str(newtag)};
end
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
