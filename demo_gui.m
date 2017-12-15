function varargout = demo_gui(varargin)
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
    handles.set_menu.Enable = 'off';
    handles.opt_wait.Enable = 'off';
    handles.opt_display.Enable = 'off';
    handles.opt_quality.Enable = 'off';
    handles.opt_statistics.Enable = 'off';
    handles.opt_probabilities.Enable = 'off';
    handles.cancel_button.Enable = 'off';
    handles.ok_button.Enable = 'off';
    demo(set,user_path,'NO_INIT','LABELLING_QUALITY',LABELLING_QUALITY,'STATISTICS',STATISTICS,...
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


