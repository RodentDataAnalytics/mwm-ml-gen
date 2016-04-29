function varargout = gui(varargin)
%% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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

%% GUI %%
% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Assign paths and initialize WIKA
initializer;
% Choose default command line output for gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

%% PATHS SECTION %%
function path_groups_Callback(hObject, eventdata, handles)
function path_groups_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');   
    end
    
function path_data_Callback(hObject, eventdata, handles)
function path_data_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end    
    
function path_output_Callback(hObject, eventdata, handles)
function path_output_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%% EXPERIMENT SETTINGS %%
function text_sessions_Callback(hObject, eventdata, handles)
function text_sessions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_tps_Callback(hObject, eventdata, handles)
function text_tps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_data_des_Callback(hObject, eventdata, handles)
function text_data_des_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_group_des_Callback(hObject, eventdata, handles)
function text_group_des_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end    

%% EXPERIMENT PROPERTIES %%
function trial_timeout_Callback(hObject, ~, handles)
function trial_timeout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centreX_Callback(hObject, eventdata, handles)
function centreX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function centreY_Callback(hObject, eventdata, handles)
function centreY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function arena_radius_Callback(hObject, eventdata, handles)
function arena_radius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function platX_Callback(hObject, eventdata, handles)
function platX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function platY_Callback(hObject, eventdata, handles)
function platY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plat_radius_Callback(hObject, eventdata, handles)
function plat_radius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plat_prox_radius_Callback(hObject, eventdata, handles)
function plat_prox_radius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function longest_loop_ext_Callback(hObject, eventdata, handles)
function longest_loop_ext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% SEGMENTATION %%
function traj_path_Callback(hObject, eventdata, handles)
function traj_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function seg_length_Callback(hObject, eventdata, handles)
function seg_length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function seg_overlap_Callback(hObject, eventdata, handles)
function seg_overlap_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% LABELLING AND CLASSIFICATION %%
function path_labels_Callback(hObject, eventdata, handles)
function path_labels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function num_clusters_Callback(hObject, eventdata, handles)   
function num_clusters_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function seg_path_Callback(hObject, eventdata, handles)
function seg_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CODE FOR ALL THE PATH TEXTS %%
function b_path_groups_Callback(hObject, eventdata, handles)
    [FN_group,PN_group] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing animal groups');
    set(handles.path_groups,'String',strcat(PN_group,FN_group));
function b_path_data_Callback(hObject, eventdata, handles)
    FN_data = uigetdir(matlabroot,'Select data folder');
    set(handles.path_data,'String',FN_data);
function b_path_output_Callback(hObject, eventdata, handles)
    FN_output = uigetdir(matlabroot,'Select output folder');
    set(handles.path_output,'String',FN_output);
function b_path_labels_Callback(hObject, eventdata, handles)
    [FN_labels,PN_labels] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels');
    set(handles.path_labels,'String',strcat(PN_labels,FN_labels));
function trajectories_data_path_Callback(hObject, eventdata, handles)
    [FN_traj,PN_traj] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select MAT file containing trajectories data');
    set(handles.traj_path,'String',strcat(PN_traj,FN_traj));
function segment_path_Callback(hObject, eventdata, handles)
    [FN_seg,PN_seg] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select MAT file containing segmentation data');
    set(handles.seg_path,'String',strcat(PN_seg,FN_seg));
function classification_path_Callback(hObject, eventdata, handles)
    [FN_class,PN_class,IND_class] = uigetfile({'*.mat','MAT-files (*.mat)'},'Select MAT files containing classification data','MultiSelect', 'on'); 
    classifications_paths = {};
    if iscell(FN_class)
        for i=1:length(FN_class)
            classifications_paths{i} = strcat(PN_class,FN_class{i},';;'); 
        end 
        set(handles.class_path,'String',strcat(cell2mat(FN_class),';'));
        set(handles.ghost_text,'String',cell2mat(classifications_paths));
    elseif FN_class~=0
        set(handles.class_path,'String',FN_class);
        set(handles.ghost_text,'String',FN_class);       
    end    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CODE FOR BUTTONS %%

function load_traj_buttom_Callback(hObject, eventdata, handles)
    paths = {get(handles.path_groups,'String'),...
             get(handles.path_data,'String'),...
             get(handles.path_output,'String')};
    experiment_settings = {get(handles.text_sessions,'String'),...
                           get(handles.text_tps,'String'),...
                           get(handles.text_data_des,'String'),...
                           get(handles.text_group_des,'String')};
    experiment_properties = {get(handles.trial_timeout,'String'),...
                             get(handles.centreX,'String'),...
                             get(handles.centreY,'String'),...
                             get(handles.arena_radius,'String'),...
                             get(handles.platX,'String'),...
                             get(handles.platY,'String'),...
                             get(handles.plat_radius,'String'),...
                             get(handles.plat_prox_radius,'String'),...
                             get(handles.longest_loop_ext,'String')};
    segmentation_properties = {get(handles.seg_length,'String'),...
                                get(handles.seg_overlap,'String')};                     
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = experiment_settings;
    user_input{1,3} = experiment_properties;
    user_input{1,4} = segmentation_properties;
    
    % Check if the information given by the user are correct
    test_result = check_user_input(user_input,1);  
    if test_result == 0 % if error
        return
    else % else update the type of variables (some will become integers)
        experiment_settings = {str2num(get(handles.text_sessions,'String')),...
                              str2num(get(handles.text_tps,'String')),...
                              get(handles.text_data_des,'String'),...
                              get(handles.text_group_des,'String')};              
        experiment_properties = {str2num(get(handles.trial_timeout,'String')),...
                                str2num(get(handles.centreX,'String')),...
                                str2num(get(handles.centreY,'String')),...
                                str2num(get(handles.arena_radius,'String')),...
                                str2num(get(handles.platX,'String')),...
                                str2num(get(handles.platY,'String')),...
                                str2num(get(handles.plat_radius,'String')),...
                                str2num(get(handles.plat_prox_radius,'String')),...
                                str2num(get(handles.longest_loop_ext,'String'))};
        segmentation_properties = {str2num(get(handles.seg_length,'String')),...
                                   str2num(get(handles.seg_overlap,'String'))};                     
        user_input{1,2} = experiment_settings;
        user_input{1,3} = experiment_properties;
        user_input{1,4} = segmentation_properties;
        % compute segments and features
        segmentation_configs = config_segments(user_input);
        % ask the user to save the config_segments object
        time = fix(clock);
        formatOut = 'yyyy-mmm-dd-HH-MM';
        time = datestr((time),formatOut);
        uisave('segmentation_configs',strcat('segmentation_configs_',time));
    end   
    
function classify_button_Callback(hObject, eventdata, handles) 
    paths = {get(handles.path_labels,'String'),...
             get(handles.seg_path,'String')};
    values = {get(handles.num_clusters,'String')};     
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = values;
    % Check if the information given by the user are correct
    test_result = check_user_input(user_input,2);  
    if test_result == 0 % if error
        return
    else % else update the type of variables (some will become integers)
        user_input{1,2} = str2num(get(handles.num_clusters,'String'));
        % run the classification
        classification_configs = config_classification(user_input);
        % ask the user to save the config_classification object
        time = fix(clock);
        formatOut = 'yyyy-mmm-dd-HH-MM';
        time = datestr((time),formatOut);
        uisave('classification_configs',strcat('classification_configs_',time));
    end   
    
function button_save_Callback(hObject, eventdata, handles)  
    paths = {get(handles.path_groups,'String'),...
             get(handles.path_data,'String'),...
             get(handles.path_output,'String')};
    experiment_settings = {get(handles.text_sessions,'String'),...
                           get(handles.text_tps,'String'),...
                           get(handles.text_data_des,'String'),...
                           get(handles.text_group_des,'String')};
    experiment_properties = {get(handles.trial_timeout,'String'),...
                             get(handles.centreX,'String'),...
                             get(handles.centreY,'String'),...
                             get(handles.arena_radius,'String'),...
                             get(handles.platX,'String'),...
                             get(handles.platY,'String'),...
                             get(handles.plat_radius,'String'),...
                             get(handles.plat_prox_radius,'String'),...
                             get(handles.longest_loop_ext,'String')};
    segmentation_properties = {get(handles.seg_length,'String'),...
                                get(handles.seg_overlap,'String')};                     
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = experiment_settings;
    user_input{1,3} = experiment_properties;
    user_input{1,4} = segmentation_properties;
    
    % Check if the information given by the user are correct
    test_result = check_user_input(user_input,1);  
    if test_result == 0 % if error
        return
    else % save to file, proposed data name is: user_input_year-month-day-hour-minute
        time = fix(clock);
        formatOut = 'yyyy-mmm-dd-HH-MM';
        time = datestr((time),formatOut);
        uisave('user_input',strcat('experiment_specs_',time));
    end

function button_load_Callback(hObject, eventdata, handles)
    % select .mat file containing previous 'user_input'
    uiopen('load');
    % test if the variable containing the data is loaded
    if exist('user_input','var') == 1
        % check if the loaded data are correct
        test_result = check_user_input(user_input,1); 
        if test_result == 0 % if error means that the file is corrupt
            errordlg('Cannot load file specified, it may be corrupted','File error');
            return
        else
            set(handles.path_groups,'String',user_input{1,1}{1});
            set(handles.path_data,'String',user_input{1,1}{2});
            set(handles.path_output,'String',user_input{1,1}{3});
            set(handles.text_sessions,'String',user_input{1,2}{1});
            set(handles.text_tps,'String',user_input{1,2}{2});
            set(handles.text_data_des,'String',user_input{1,2}{3});
            set(handles.text_group_des,'String',user_input{1,2}{4});
            set(handles.trial_timeout,'String',user_input{1,3}{1});
            set(handles.centreX,'String',user_input{1,3}{2});
            set(handles.centreY,'String',user_input{1,3}{3});
            set(handles.arena_radius,'String',user_input{1,3}{4});
            set(handles.platX,'String',user_input{1,3}{5});
            set(handles.platY,'String',user_input{1,3}{6});
            set(handles.plat_radius,'String',user_input{1,3}{7});
            set(handles.plat_prox_radius,'String',user_input{1,3}{8});
            set(handles.longest_loop_ext,'String',user_input{1,3}{9});
            set(handles.seg_length,'String',user_input{1,4}{1});
            set(handles.seg_overlap,'String',user_input{1,4}{2});
        end
    else
        errordlg('The file specified is not containing the appropriate data format.','File error');
    end
    
function button_cancel_Callback(hObject, eventdata, handles)
    close(gui);

function browse_trajectories_Callback(hObject, eventdata, handles)
    run browse_trajectories;
    
    
