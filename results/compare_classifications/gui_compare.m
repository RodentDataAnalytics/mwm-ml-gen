function varargout = gui_compare(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_compare_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_compare_OutputFcn, ...
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


% --- Executes just before gui_compare is made visible.
function gui_compare_OpeningFcn(hObject, eventdata, handles, varargin)
    if ~isempty(varargin)
        set(handles.gui_compare,'UserData',varargin{1});  
    end 
    handles.output = hObject;
    guidata(hObject, handles);
    if ~isempty(varargin)
        uiwait(handles.gui_compare);
    end

% --- Outputs from this function are returned to the command line.
function varargout = gui_compare_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    if ~isempty(get(handles.gui_compare,'UserData'))
        delete(handles.gui_compare);
    end
function close_fnc_Callback(hObject, eventdata, handles)
    gui_compare_CloseRequestFcn(hObject, eventdata, handles)
function gui_compare_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.gui_compare, 'waitstatus'), 'waiting')
        uiresume(handles.gui_compare);
    else
        delete(handles.gui_compare);
    end

function ok_Callback(hObject, eventdata, handles)
    project_path = get(handles.gui_compare,'UserData');
    project_path = char_project_path(project_path);
    f1 = get(handles.edit1,'String');
    f2 = get(handles.edit2,'String');     
    if isempty(f1) || isempty(f2) || isequal(f1,f2)
        errordlg('Two different classifications have to be specified.','Error');
        return;
    end
    f1 = char_project_path(f1);
    f2 = char_project_path(f2);
    classifications = {f1,f2};
    error = compare_classifications(classifications,project_path);
    if error
        return;
    end
    
function exit_Callback(hObject, eventdata, handles)
    close_fnc_Callback(hObject, eventdata, handles)
    
function pathstr = uiget(handles)
    project_path = get(handles.gui_compare,'UserData');
    project_path = char_project_path(project_path);
    if isempty(project_path)
        project_path = matlabroot;
    end  
    pathstr = uigetdir(project_path,'Select classification folder');
    if isnumeric(pathstr)
        return
    end   
    files = dir(fullfile(pathstr,'*.mat'));
    if isempty(files)
        errordlg('The selectedfolder contains no MAT files','Empty folder');
        return;
    end  
    
function pushbutton1_Callback(hObject, eventdata, handles)
    str = uiget(handles);
    if isequal(str,0)
        return
    end
    set(handles.edit1,'String',str);    
    
function pushbutton2_Callback(hObject, eventdata, handles)
    str = uiget(handles);
    if isequal(str,0)
        return
    end
    set(handles.edit2,'String',str);  

function edit1_Callback(hObject, eventdata, handles)
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_Callback(hObject, eventdata, handles)
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
