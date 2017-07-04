function varargout = advanced_gui(varargin)
% ADVANCED_GUI MATLAB code for advanced_gui.fig
%      ADVANCED_GUI, by itself, creates a new ADVANCED_GUI or raises the existing
%      singleton*.
%
%      H = ADVANCED_GUI returns the handle to a new ADVANCED_GUI or the handle to
%      the existing singleton*.
%
%      ADVANCED_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADVANCED_GUI.M with the given input arguments.
%
%      ADVANCED_GUI('Property','Value',...) creates a new ADVANCED_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before advanced_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to advanced_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help advanced_gui

% Last Modified by GUIDE v2.5 22-May-2017 13:33:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advanced_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @advanced_gui_OutputFcn, ...
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


% --- Executes just before advanced_gui is made visible.
function advanced_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    pre_values = varargin{1};
    if ~isempty(pre_values)
        if pre_values(1) == 3
            set(handles.group_strategy,'SelectedObject',handles.r_smooth);
        elseif pre_values(1) == 2
            set(handles.group_strategy,'SelectedObject',handles.r_Nsmooth);
        else
            set(handles.group_strategy,'SelectedObject',handles.r_smooth);
        end
        if pre_values(2) == 3
            set(handles.group_transitions,'SelectedObject',handles.t_smooth);
        elseif pre_values(2) == 2
            set(handles.group_transitions,'SelectedObject',handles.t_Nsmooth);
        else
            set(handles.group_transitions,'SelectedObject',handles.t_smooth);
        end    
        if pre_values(3) ~= 0 || pre_values(4) ~= 0
            set(handles.sfiltering,'SelectedObject',handles.b_smoothingON);
            set(handles.v_sigma,'String',pre_values(3));
            set(handles.v_interval,'String',pre_values(4));
            if pre_values(5) == 0
                set(handles.a_sigma,'Value',0);
            else
                set(handles.a_sigma,'Value',1);
            end
            if pre_values(6) == 0
                set(handles.a_interval,'Value',0);
            else
                set(handles.a_interval,'Value',1);
            end                  
        else
            set(handles.sfiltering,'SelectedObject',handles.b_smoothingOFF);
            set(handles.v_sigma,'Enable','off');
            set(handles.v_interval,'Enable','off');
            set(handles.a_sigma,'Enable','off');
            set(handles.a_interval,'Enable','off');    
        end 
    else
        set(handles.group_strategy,'SelectedObject',handles.r_smooth);
        set(handles.group_transitions,'SelectedObject',handles.t_smooth);
        set(handles.sfiltering,'SelectedObject',handles.b_smoothingOFF);
        set(handles.v_sigma,'Enable','off');
        set(handles.v_interval,'Enable','off');
        set(handles.a_sigma,'Enable','off');
        set(handles.a_interval,'Enable','off');        
    end
    % Choose default command line output for advanced_gui
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes advanced_gui wait for user response (see UIRESUME)
    uiwait(handles.advanced_gui);

% --- Outputs from this function are returned to the command line.
function varargout = advanced_gui_OutputFcn(hObject, eventdata, handles)   
    tmp = get(handles.r_smooth,'Value');
    if tmp
        STR_DISTR = 3;
    else
        STR_DISTR = 2;
    end
    %get(handles.r_Nsmooth,'Value');
    tmp = get(handles.t_smooth,'Value');
    if tmp
        TRANS_DISTR = 3;
    else
        TRANS_DISTR = 2;
    end
    %get(handles.t_Nsmooth,'Value');    
    tmp = get(handles.b_smoothingOFF,'Value');
    %get(handles.b_smoothingON,'Value'); 
    if tmp
        SIGMA = 0;
        INTERVAL = 0;
        R_SIGMA = 0;
        R_INTERVAL = 0;
    else    
        SIGMA = str2double(get(handles.v_sigma,'String'));
        INTERVAL = str2double(get(handles.v_interval,'String'));
        R_SIGMA = get(handles.a_sigma,'Value');
        R_INTERVAL = get(handles.a_interval,'Value');   
        %unnecessary test
%         if isnan(SIGMA) || isnan(INTERVAL) || SIGMA <= 0 || INTERVAL <= 0
%             STR_DISTR = 3;
%             TRANS_DISTR = 3;
%             SIGMA = 0;
%             INTERVAL = 0;
%             R_SIGMA = 0;
%             R_INTERVAL = 0;   
%             warndlg('SIGMA and INTERVAL need to have positive and non-zero values. Default values were assigned.','Warning');
%         end          
    end
    % Get default command line output from handles structure
    varargout{1} = [STR_DISTR,TRANS_DISTR,SIGMA,INTERVAL,R_SIGMA,R_INTERVAL];
    % The figure can be deleted now
    delete(handles.advanced_gui);
    
function advanced_gui_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.advanced_gui, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.advanced_gui);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.advanced_gui);
    end

function v_sigma_Callback(hObject, eventdata, handles)
function v_sigma_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function v_interval_Callback(hObject, eventdata, handles)
function v_interval_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function a_sigma_Callback(hObject, eventdata, handles)
function a_interval_Callback(hObject, eventdata, handles)
function b_smoothingOFF_Callback(hObject, eventdata, handles)
    set(handles.v_sigma,'Enable','off');
    set(handles.v_interval,'Enable','off');
    set(handles.a_sigma,'Enable','off');
    set(handles.a_interval,'Enable','off');      
function b_smoothingON_Callback(hObject, eventdata, handles)
    set(handles.v_sigma,'Enable','on');
    set(handles.v_interval,'Enable','on');
    set(handles.a_sigma,'Enable','on');
    set(handles.a_interval,'Enable','on');  
function r_smooth_Callback(hObject, eventdata, handles)
function r_Nsmooth_Callback(hObject, eventdata, handles)

function group_strategy_CreateFcn(hObject, eventdata, handles)
function group_transitions_CreateFcn(hObject, eventdata, handles)
function sfiltering_CreateFcn(hObject, eventdata, handles)

function bcancel_Callback(hObject, eventdata, handles)
    set(handles.group_strategy,'SelectedObject',handles.r_smooth);
    set(handles.group_transitions,'SelectedObject',handles.t_smooth);
    set(handles.sfiltering,'SelectedObject',handles.b_smoothingOFF);
    set(handles.v_sigma,'Enable','off');
    set(handles.v_interval,'Enable','off');
    set(handles.a_sigma,'Enable','off');
    set(handles.a_interval,'Enable','off');
    advanced_gui_CloseRequestFcn(hObject, eventdata, handles);
function bok_Callback(hObject, eventdata, handles)
    e = get(handles.b_smoothingON,'Value');
    if e == 1
        txt = get(handles.v_sigma,'String');
        txt = str2double(txt);
        if isnan(txt) || length(txt) > 1
            errordlg('Wrong input for Sigma. It needs to have a non-zero positive value.','Error');
            return;
        end    
        if txt <= 0
            errordlg('Wrong input for Sigma. It needs to have a non-zero positive value.','Error');
            return;            
        end
        txt = get(handles.v_interval,'String');
        txt = str2double(txt);
        if isnan(txt) || length(txt) > 1
            errordlg('Wrong input for Interval. It needs to have a non-zero positive value.','Error');
            return;
        end
        if txt <= 0
            errordlg('Wrong input for Interval. It needs to have a non-zero positive value.','Error');
            return;            
        end        
    end
    advanced_gui_CloseRequestFcn(hObject, eventdata, handles);
