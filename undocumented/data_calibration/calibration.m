function varargout = calibration(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @calibration_OpeningFcn, ...
                   'gui_OutputFcn',  @calibration_OutputFcn, ...
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


% --- Executes just before calibration is made visible.
function calibration_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for calibration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = calibration_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


%% PATHS %%
function data_dir_Callback(hObject, eventdata, handles)
    FN_data = uigetdir(matlabroot,'Select data folder');
    if isnumeric(FN_data)
       return
    end       
    set(handles.data_path,'String',FN_data);

%% TEXTFIELDS %%
function t_field_Callback(hObject, eventdata, handles)
function t_field_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function x_field_Callback(hObject, eventdata, handles)
function x_field_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function y_field_Callback(hObject, eventdata, handles)
function y_field_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function arena_Callback(hObject, eventdata, handles)
function arena_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function x_Callback(hObject, eventdata, handles)
function x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function y_Callback(hObject, eventdata, handles)
function y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% BUTTON %%
function calibrate_traj_Callback(hObject, eventdata, handles)
    % get user input
    paths = {get(handles.data_path,'String')};
    format = {get(handles.t_field,'String'),...
              get(handles.x_field,'String'),...
              get(handles.y_field,'String'),...
              get(handles.arena,'String'),...
              get(handles.x,'String'),...
              get(handles.y,'String')};
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = format;   
    % check user input
    test_result = check_user_input(user_input,4);  
    if test_result == 0 % if error
        return;
    else
        format = {get(handles.t_field,'String'),...
               get(handles.x_field,'String'),...
               get(handles.y_field,'String'),...
               str2num(get(handles.arena,'String')),...
               str2num(get(handles.x,'String')),...
               str2num(get(handles.y,'String'))};     
        cal_data = load_calibration_data(paths,format);    
        if isempty(cal_data)
            return;
        end    
        fn = strcat(get(handles.data_path,'String'),'/','_cal_data.mat');
        save(fn,'cal_data');
    end    
