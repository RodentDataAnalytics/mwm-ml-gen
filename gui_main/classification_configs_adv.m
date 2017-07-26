function varargout = classification_configs(varargin)
% CLASSIFICATION_CONFIGS_ADV MATLAB code for classification_configs_adv.fig
%      CLASSIFICATION_CONFIGS_ADV, by itself, creates a new CLASSIFICATION_CONFIGS_ADV or raises the existing
%      singleton*.
%
%      H = CLASSIFICATION_CONFIGS_ADV returns the handle to a new CLASSIFICATION_CONFIGS_ADV or the handle to
%      the existing singleton*.
%
%      CLASSIFICATION_CONFIGS_ADV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLASSIFICATION_CONFIGS_ADV.M with the given input arguments.
%
%      CLASSIFICATION_CONFIGS_ADV('Property','Value',...) creates a new CLASSIFICATION_CONFIGS_ADV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before classification_configs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to classification_configs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help classification_configs_adv

% Last Modified by GUIDE v2.5 24-Jul-2017 17:11:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @classification_configs_adv_OpeningFcn, ...
                   'gui_OutputFcn',  @classification_configs_adv_OutputFcn, ...
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


% --- Executes just before classification_configs_adv is made visible.
function classification_configs_adv_OpeningFcn(hObject, eventdata, handles, varargin)
    pre_values = varargin{1};
    if ~isempty(pre_values)
        set(handles.cv_error,'String',pre_values(1));
        set(handles.cv_k,'String',pre_values(2));    
        set(handles.pool_start,'String',pre_values(3));
        set(handles.pool_end,'String',pre_values(4));   
        set(handles.pool_size,'String',pre_values(5));
    end
    % Choose default command line output for classification_configs_adv
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes classification_configs_adv wait for user response (see UIRESUME)
    uiwait(handles.classification_configs_adv);

% --- Outputs from this function are returned to the command line.
function varargout = classification_configs_adv_OutputFcn(hObject, eventdata, handles) 
    vector = [0,0,0,0,0,0];
    vector(1) = str2double(get(handles.cv_error,'String'));
    vector(2) = str2double(get(handles.cv_k,'String'));    
    vector(3) = str2double(get(handles.pool_start,'String'));
    vector(4) = str2double(get(handles.pool_end,'String'));   
    vector(5) = str2double(get(handles.pool_size,'String'));
    vector(6) = str2double(get(handles.cv_ks,'String'));
    % Get default command line output from handles structure    
    varargout{1} = vector;
    % The figure can be deleted now
    delete(handles.classification_configs_adv);
    
function classification_configs_adv_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.classification_configs_adv, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.classification_configs_adv);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.classification_configs_adv);
    end

function CANCEL_Callback(hObject, eventdata, handles)
    set(handles.cv_error,'String','0');
    set(handles.cv_k,'String','100');    
    set(handles.pool_start,'String','0');
    set(handles.pool_end,'String','25');   
    set(handles.pool_size,'String','40');   
    set(handles.cv_ks,'String','0');
    classification_configs_adv_CloseRequestFcn(hObject, eventdata, handles);
function OK_Callback(hObject, eventdata, handles)
    classification_configs_adv_CloseRequestFcn(hObject, eventdata, handles);
function default_values_Callback(hObject, eventdata, handles)
    set(handles.cv_error,'String','0');
    set(handles.cv_k,'String','100');    
    set(handles.pool_start,'String','0');
    set(handles.pool_end,'String','25');   
    set(handles.pool_size,'String','40');    
    set(handles.cv_ks,'String','0');
%% INCREASE COUNTERS
function increase(hObject, eventdata, handles)
    tmp = eventdata.Source.Tag;
    switch tmp
        case 'cv_error_up'
            a = str2double(get(handles.cv_error,'String'));
            if a == 100
                return
            end
            a = a + 1;
            set(handles.cv_error,'String',num2str(a));
        case 'cv_k_up'
            a = str2double(get(handles.cv_k,'String'));
            if a == 300
                return
            end
            a = a + 1;
            set(handles.cv_k,'String',num2str(a));    
        case 'cv_ks_up'    
            a = str2double(get(handles.cv_ks,'String'));
            tmp = str2double(get(handles.cv_k,'String'));
            if a == tmp
                return
            end
            a = a + 1;
            set(handles.cv_k,'String',num2str(a));             
        case 'pool_start_up'
            a = str2double(get(handles.pool_start,'String'));
            if a == 100
                return
            end
            a = a + 1;
            set(handles.pool_start,'String',num2str(a));  
        case 'pool_end_up'
            a = str2double(get(handles.pool_end,'String'));
            if a == 100
                return
            end
            a = a + 1;
            set(handles.pool_end,'String',num2str(a));             
        case 'pool_size_up'
            a1 = str2double(get(handles.pool_size,'String'));
            a2 = str2double(get(handles.cv_k,'String'));
            if a1 == a2
                return
            end
            a1 = a1 + 1;
            set(handles.pool_size,'String',num2str(a1));   
    end
%% DECREASE COUNTERS                          
function decrease(hObject, eventdata, handles)
    tmp = eventdata.Source.Tag;
    switch tmp
        case 'cv_error_down'
            a = str2double(get(handles.cv_error,'String'));
            if a == 0
                return
            end
            a = a - 1;
            set(handles.cv_error,'String',num2str(a));
        case 'cv_k_down'
            a = str2double(get(handles.cv_k,'String'));
            if a == 0
                return
            end
            a = a - 1;
            set(handles.cv_k,'String',num2str(a));    
        case 'cv_ks_down'   
            a = str2double(get(handles.cv_ks,'String'));
            if a == 0
                return
            end
            a = a - 1;
            set(handles.cv_k,'String',num2str(a));             
        case 'pool_start_down'
            a = str2double(get(handles.pool_start,'String'));
            if a == 0
                return
            end
            a = a - 1;
            set(handles.pool_start,'String',num2str(a));  
        case 'pool_end_down'
            a = str2double(get(handles.pool_end,'String'));
            if a == 0
                return
            end
            a = a - 1;
            set(handles.pool_end,'String',num2str(a));              
        case 'pool_size_down'
            a = str2double(get(handles.pool_size,'String'));
            if a == 0
                return
            end
            a = a - 1;
            set(handles.pool_size,'String',num2str(a));   
    end

    
function pool_start_Callback(hObject, eventdata, handles)
function pool_start_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pool_start_up_Callback(hObject, eventdata, handles)
    increase(hObject, eventdata, handles)
function pool_start_down_Callback(hObject, eventdata, handles)
    decrease(hObject, eventdata, handles)
function pool_end_Callback(hObject, eventdata, handles)
function pool_end_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pool_end_up_Callback(hObject, eventdata, handles)
    increase(hObject, eventdata, handles)
function pool_end_down_Callback(hObject, eventdata, handles)
    decrease(hObject, eventdata, handles)
function pool_size_Callback(hObject, eventdata, handles)
function pool_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pool_size_up_Callback(hObject, eventdata, handles)
    increase(hObject, eventdata, handles)
function pool_size_down_Callback(hObject, eventdata, handles)
    decrease(hObject, eventdata, handles)
function cv_error_Callback(hObject, eventdata, handles)
function cv_error_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function cv_error_up_Callback(hObject, eventdata, handles)
    increase(hObject, eventdata, handles)
function cv_error_down_Callback(hObject, eventdata, handles)
    decrease(hObject, eventdata, handles)
function cv_k_Callback(hObject, eventdata, handles)
function cv_k_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function cv_k_up_Callback(hObject, eventdata, handles)
    increase(hObject, eventdata, handles)
function cv_k_down_Callback(hObject, eventdata, handles)
    decrease(hObject, eventdata, handles)
function cv_ks_Callback(hObject, eventdata, handles)
function cv_ks_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function cv_ks_up_Callback(hObject, eventdata, handles)
    increase(hObject, eventdata, handles)
function cv_ks_down_Callback(hObject, eventdata, handles)
    decrease(hObject, eventdata, handles)
