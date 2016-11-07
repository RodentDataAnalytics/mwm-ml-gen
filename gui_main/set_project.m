function varargout = set_project(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @set_project_OpeningFcn, ...
                   'gui_OutputFcn',  @set_project_OutputFcn, ...
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
% --- Executes just before set_project is made visible.
function set_project_OpeningFcn(hObject, eventdata, handles, varargin)
    set(handles.project_path,'String',varargin{1});
    set(handles.project_path,'UserData',varargin{1});
    % Choose default command line output for set_project
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes set_project wait for user response (see UIRESUME)
    uiwait(handles.set_project);
% --- Outputs from this function are returned to the command line.
function varargout = set_project_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = get(handles.ok_button,'UserData');
    % The figure can be deleted now
    delete(handles.set_project);
function set_project_CloseRequestFcn(hObject, eventdata, handles)
%code from http://blogs.mathworks.com/videos/2010/02/12/advanced-getting-an-output-from-a-guide-gui/
    if isequal(get(handles.set_project, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.set_project);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.set_project);
    end

function project_path_Callback(hObject, eventdata, handles)
function project_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function set_project_path_Callback(hObject, eventdata, handles)
    main_path = get(handles.project_path,'UserData');
    main_path = main_path{1};
    FN_data = uigetdir(main_path,'Select data folder');
    if isnumeric(FN_data)
       return
    end       
    set(handles.project_path,'String',FN_data); 
function project_name_Callback(hObject, eventdata, handles)
function project_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ok_button_Callback(hObject, eventdata, handles)
    ppath = get(handles.project_path,'String');
    name = get(handles.project_name,'String');
    if isempty(name)
        errordlg('Project name not specified','Error');
        return
    elseif isempty(path) 
        errordlg('Project path not specified','Error');
        return
    end    
    error = build_folder_tree(ppath, name);
    if error
        return;
    else
        ppath = fullfile(ppath,name);
        set(handles.ok_button,'UserData',ppath);
        set_project_CloseRequestFcn(hObject, eventdata, handles);
    end
function cancel_button_Callback(hObject, eventdata, handles)
    set_project_CloseRequestFcn(hObject, eventdata, handles);

