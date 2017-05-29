function varargout = demo_gui(varargin)
% DEMO_GUI MATLAB code for demo_gui.fig
%      DEMO_GUI, by itself, creates a new DEMO_GUI or raises the existing
%      singleton*.
%
%      H = DEMO_GUI returns the handle to a new DEMO_GUI or the handle to
%      the existing singleton*.
%
%      DEMO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEMO_GUI.M with the given input arguments.
%
%      DEMO_GUI('Property','Value',...) creates a new DEMO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before demo_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to demo_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help demo_gui

% Last Modified by GUIDE v2.5 29-May-2017 10:33:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_gui_OutputFcn, ...
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


% --- Executes just before demo_gui is made visible.
function demo_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    main_path = initialization;
    str = {'1'};
    set(handles.set_menu,'String',str);
    set(handles.set_menu,'Value',1);
    set(handles.demo_gui,'UserData',main_path);
    handles.output = hObject;
    guidata(hObject, handles);
    uiwait(handles.demo_gui);
function varargout = demo_gui_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    if ~isempty(get(handles.demo_gui,'UserData'))
        delete(handles.demo_gui);
    end    
function demo_gui_DeleteFcn(hObject, eventdata, handles)
    if isequal(get(handles.demo_gui, 'waitstatus'), 'waiting')
        uiresume(handles.demo_gui);
    else
        delete(handles.demo_gui);
    end
function demo_gui_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.demo_gui, 'waitstatus'), 'waiting')
        uiresume(handles.demo_gui);
    else
        delete(handles.demo_gui);
    end   
    
function ok_button_Callback(hObject, eventdata, handles)    
    user_path = get(handles.demo_gui,'UserData');
    set = get(handles.set_menu,'Value');
    LABELLING_QUALITY = get(handles.opt_quality,'Value');
    STATISTICS = get(handles.opt_statistics,'Value');
    PROBABILITIES = get(handles.opt_probabilities,'Value');
    WAITBAR = get(handles.opt_wait,'Value');
    DISPLAY = get(handles.opt_display,'Value');
    demo(set,user_path,'LABELLING_QUALITY',LABELLING_QUALITY,'STATISTICS',STATISTICS,...
        'PROBABILITIES',PROBABILITIES,'WAITBAR',WAITBAR,'DISPLAY',DISPLAY);
    demo_gui_CloseRequestFcn(hObject, eventdata, handles);
    
function cancel_button_Callback(hObject, eventdata, handles)
    demo_gui_CloseRequestFcn(hObject, eventdata, handles);  
    
function set_menu_Callback(hObject, eventdata, handles)
function set_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function opt_wait_Callback(hObject, eventdata, handles)
function opt_display_Callback(hObject, eventdata, handles)
function opt_quality_Callback(hObject, eventdata, handles)
function opt_statistics_Callback(hObject, eventdata, handles)
function opt_probabilities_Callback(hObject, eventdata, handles)


