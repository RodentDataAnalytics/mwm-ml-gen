function varargout = fix_trajectories(varargin)
% FIX_TRAJECTORIES MATLAB code for fix_trajectories.fig
%      FIX_TRAJECTORIES, by itself, creates a new FIX_TRAJECTORIES or raises the existing
%      singleton*.
%
%      H = FIX_TRAJECTORIES returns the handle to a new FIX_TRAJECTORIES or the handle to
%      the existing singleton*.
%
%      FIX_TRAJECTORIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIX_TRAJECTORIES.M with the given input arguments.
%
%      FIX_TRAJECTORIES('Property','Value',...) creates a new FIX_TRAJECTORIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fix_trajectories_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fix_trajectories_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fix_trajectories

% Last Modified by GUIDE v2.5 23-Jun-2017 11:58:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fix_trajectories_OpeningFcn, ...
                   'gui_OutputFcn',  @fix_trajectories_OutputFcn, ...
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


% --- Executes just before fix_trajectories is made visible.
function fix_trajectories_OpeningFcn(hObject, eventdata, handles, varargin)
    if ~isempty(varargin)
        set(handles.fix_trajectories,'UserData',varargin{1});  
    end  
    set(handles.b_delete,'Enable','off');
    set(handles.b_save,'Enable','off');
    % Choose default command line output for fix_trajectories
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes fix_trajectories wait for user response (see UIRESUME)
    % uiwait(handles.fix_trajectories);
    
% --- Outputs from this function are returned to the command line.
function varargout = fix_trajectories_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;

    
function b_load_Callback(hObject, eventdata, handles)
    project_path = get(handles.fix_trajectories,'UserData');
    [ mode, obj ] = browse_activation_function(project_path);
    if mode == 3 %Accept only my_trajectories.mat files
        try    
            load(fullfile(char_project_path(project_path),'settings','new_properties.mat'));
        catch
            errordlg('Cannot find project settings','Error');
            return        
        end
        % plot the arena
        cla
        plot_arena('',new_properties{:});   
        % plot the first trajectory
        plot_trajectory(obj.items(1,1));    
        set(handles.navigator,'String',1);
        coords = fill_coordinates_table(obj, 1);
        set(handles.coord_table,'data',coords);
        set(handles.ok,'UserData',new_properties);     
        set(handles.b_load,'UserData',obj);
        set(handles.plotter,'UserData',mode);
        set(handles.b_delete,'Enable','on');
        set(handles.b_save,'Enable','on');
    else
        errordlg('Select a my_trajectories.mat file','Error');
        return
    end
function b_save_Callback(hObject, eventdata, handles)
    project_path = get(handles.fix_trajectories,'UserData');
    p = fullfile(char_project_path(project_path),'settings','my_trajectories.mat');
    load(p);
    p = fullfile(char_project_path(project_path),'settings','my_trajectories_original.mat');
    save(p,'my_trajectories');
    p = fullfile(char_project_path(project_path),'settings','my_trajectories.mat');
    delete(p);
    my_trajectories = get(handles.b_load,'UserData');
    save(p,'my_trajectories');
        
function b_delete_Callback(hObject, eventdata, handles)
    c = get(handles.navigator,'UserData');
    coords = get(handles.coord_table,'data');
    trajs = get(handles.b_load,'UserData');
    new_properties = get(handles.ok,'UserData');
    idx = str2double(get(handles.navigator,'String'));  
    c = c(:,1);
    coords(c,:) = []; 
    trajs.items(idx).points = coords;
    %update table
    set(handles.coord_table,'data',coords);
    %update plot
    cla
    plot_arena('',new_properties{:});   
    plot_trajectory(trajs.items(1,idx));    
    %store
    set(handles.b_load,'UserData',trajs);
    
    
%% TABLE 
function coord_table_CreateFcn(hObject, eventdata, handles)
function coord_table_CellSelectionCallback(hObject, eventdata, handles)
    tmp = get(handles.coord_table,'data');
    c = eventdata.Indices;
    try
        for i = 1:size(c,1)
            if isempty(tmp(c(i),c(2)))
                return
            end
        end
    catch
        return
    end
    set(handles.navigator,'UserData',c);
    

%% PLOTTER
function previous_arrow_Callback(hObject, eventdata, handles)
    error = browse_navigation(handles,3);
    if error
        return
    end  
function next_arrow_Callback(hObject, eventdata, handles)
    error = browse_navigation(handles,2);
    if error
        return
    end  
function ok_Callback(hObject, eventdata, handles)
    error = browse_navigation(handles,1);
    if error
        return
    end  
function navigator_Callback(hObject, eventdata, handles)
function navigator_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function plotter_CreateFcn(hObject, eventdata, handles)
    axis off;





