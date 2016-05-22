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
% Assign default paths and initialize WIKA
path = initializer;
weka_init;
%set(handles.path_groups,'String',strcat(path{1,2},'/trajectory_groups.csv'));
%set(handles.path_data,'String',path{1,2});
set(handles.path_output,'String',path{1,1});
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
    
%% FILE FORMAT %%
function field_id_Callback(hObject, eventdata, handles)
function field_id_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function field_group_Callback(hObject, eventdata, handles)
function field_group_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function field_trial_Callback(hObject, eventdata, handles)
function field_trial_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function field_time_Callback(hObject, eventdata, handles)
function field_time_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function field_x_Callback(hObject, eventdata, handles)
function field_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function field_y_Callback(hObject, eventdata, handles)
function field_y_CreateFcn(hObject, eventdata, handles)
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

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CODE FOR BUTTONS %%
function load_traj_buttom_Callback(hObject, eventdata, handles)
    paths = {get(handles.path_groups,'String'),...
             get(handles.path_data,'String'),...
             get(handles.path_output,'String')};
    format = {get(handles.field_id,'String'),...
              get(handles.field_group,'String'),...
              get(handles.field_trial,'String'),...
              get(handles.field_time,'String'),...
              get(handles.field_x,'String'),...
              get(handles.field_y,'String')};
    experiment_settings = {get(handles.text_sessions,'String'),...
                           get(handles.text_tps,'String')};
    experiment_properties = {get(handles.trial_timeout,'String'),...
                             get(handles.centreX,'String'),...
                             get(handles.centreY,'String'),...
                             get(handles.arena_radius,'String'),...
                             get(handles.platX,'String'),...
                             get(handles.platY,'String'),...
                             get(handles.plat_radius,'String')};
    segmentation_properties = {get(handles.seg_length,'String'),...
                               get(handles.seg_overlap,'String')};                     
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = format;
    user_input{1,3} = experiment_settings;
    user_input{1,4} = experiment_properties;
    user_input{1,5} = segmentation_properties;
    % Check if the information given by the user are correct
    test_result = check_user_input(user_input,2);  
    if test_result == 0 % if error
        return
    else % else update the type of variables (some will become integers)
        paths = {get(handles.path_groups,'String'),...
                 get(handles.path_data,'String'),...
                 get(handles.path_output,'String')};
        format = {get(handles.field_id,'String'),...
                  get(handles.field_group,'String'),...
                  get(handles.field_trial,'String'),...
                  get(handles.field_time,'String'),...
                  get(handles.field_x,'String'),...
                  get(handles.field_y,'String')};
        experiment_settings = {str2num(get(handles.text_sessions,'String')),...
                               str2num(get(handles.text_tps,'String'))};
        experiment_properties = {str2num(get(handles.trial_timeout,'String')),...
                                str2num(get(handles.centreX,'String')),...
                                str2num(get(handles.centreY,'String')),...
                                str2num(get(handles.arena_radius,'String')),...
                                str2num(get(handles.platX,'String')),...
                                str2num(get(handles.platY,'String')),...
                                str2num(get(handles.plat_radius,'String'))};
        segmentation_properties = {str2num(get(handles.seg_length,'String')),...
                                   str2num(get(handles.seg_overlap,'String'))};                     
        user_input = {};
        user_input{1,1} = paths;
        user_input{1,2} = format;
        user_input{1,3} = experiment_settings;
        user_input{1,4} = experiment_properties;
        user_input{1,5} = segmentation_properties;
                     
        % compute segments and features
        segmentation_configs = config_segments(user_input);
        if isempty(segmentation_configs.TRAJECTORIES.items)
            return;
        end    
        % check if object is already cached and if not save it
        rpath = check_cached_objects(segmentation_configs,1);
        set(handles.seg_path,'String',rpath);
    end   
    
function classify_button_Callback(hObject, eventdata, handles) 
    paths = {get(handles.path_labels,'String'),...
             get(handles.seg_path,'String')};
    values = {get(handles.num_clusters,'String')};     
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = values;
    % Check if the information given by the user are correct
    test_result = check_user_input(user_input,3);  
    if test_result == 0 % if error
        return
    else % else update the type of variables (some will become integers)
        user_input{1,2} = str2num(get(handles.num_clusters,'String'));
        % run the classification
        classification_configs = config_classification(user_input);
        % check if object is already cached and if not save it
        rpath = check_cached_objects(classification_configs,2);
    end   
    
function button_save_Callback(hObject, eventdata, handles)  
    paths = {get(handles.path_groups,'String'),...
             get(handles.path_data,'String'),...
             get(handles.path_output,'String')};
    format = {get(handles.field_id,'String'),...
              get(handles.field_group,'String'),...
              get(handles.field_trial,'String'),...
              get(handles.field_time,'String'),...
              get(handles.field_x,'String'),...
              get(handles.field_y,'String')};
    experiment_settings = {get(handles.text_sessions,'String'),...
                           get(handles.text_tps,'String')};
    experiment_properties = {get(handles.trial_timeout,'String'),...
                             get(handles.centreX,'String'),...
                             get(handles.centreY,'String'),...
                             get(handles.arena_radius,'String'),...
                             get(handles.platX,'String'),...
                             get(handles.platY,'String'),...
                             get(handles.plat_radius,'String')};                    
    user_input = {};
    user_input{1,1} = paths;
    user_input{1,2} = format;
    user_input{1,3} = experiment_settings;
    user_input{1,4} = experiment_properties;
    
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
            
            set(handles.field_id,'String',user_input{1,2}{1});
            set(handles.field_group,'String',user_input{1,2}{2});
            set(handles.field_trial,'String',user_input{1,2}{3});
            set(handles.field_time,'String',user_input{1,2}{4});
            set(handles.field_x,'String',user_input{1,2}{5});
            set(handles.field_y,'String',user_input{1,2}{6});
            
            set(handles.text_sessions,'String',user_input{1,3}{1});
            set(handles.text_tps,'String',user_input{1,3}{2});

            set(handles.trial_timeout,'String',user_input{1,4}{1});
            set(handles.centreX,'String',user_input{1,4}{2});
            set(handles.centreY,'String',user_input{1,4}{3});
            set(handles.arena_radius,'String',user_input{1,4}{4});
            set(handles.platX,'String',user_input{1,4}{5});
            set(handles.platY,'String',user_input{1,4}{6});
            set(handles.plat_radius,'String',user_input{1,4}{7});
        end
    else
        errordlg('The file specified is not containing the appropriate data format.','File error');
    end
    
function button_cancel_Callback(hObject, eventdata, handles)
    close(gui);

function browse_trajectories_Callback(hObject, eventdata, handles)
    run browse_trajectories;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CODE FOR RESULTS BUTTONS %%

function res_test_Callback(hObject, eventdata, handles)
    published_results('execute');

function lat_sp_len_Callback(hObject, eventdata, handles)
    % ask for segmentation_config file
    segmentation_configs = select_files(1);
    if isempty(segmentation_configs)
        return
    end    
    % find available animal groups
    groups = zeros(1,length(segmentation_configs.TRAJECTORIES.items));
    for i = 1:length(segmentation_configs.TRAJECTORIES.items)
        groups(1,i) = segmentation_configs.TRAJECTORIES.items(1,i).group;
    end
    groups = unique(groups);
    if length(groups) > 1
    % ask which one or two animal groups
        prompt={'Choose one or two animal groups (example: 2 or 1,3)'};
        name = 'Choose groups';
        defaultans = {''};
        options.Interpreter = 'tex';
        user = inputdlg(prompt,name,[1 30],defaultans,options);
        results_latency_speed_length(segmentation_configs,user);
    else
    % there is only one group thus take all the animals
        results_latency_speed_length(segmentation_configs);
    end  


function clustering_performance_Callback(hObject, eventdata, handles)
    % ask for segmentation_config file
    segmentation_configs = select_files(1);
    if isempty(segmentation_configs)
        return
    end  
    % ask for labels file
    labels_path = select_files(1);
    if isempty(labels_path)
        return
    end  
    % run the result
    results_clustering_parameters(segmentation_configs,labels_path);
    

function strategies_distribution_Callback(hObject, eventdata, handles)
    % ask for segmentation_config file
    segmentation_configs = select_files(1);
    if isempty(segmentation_configs)
        return
    end  
    % ask for classification_config file
    classification_configs = select_files(3);
    if isempty(classification_configs)
        return
    end  
    % find available animal groups
    groups = zeros(1,length(segmentation_configs.TRAJECTORIES.items));
    for i = 1:length(segmentation_configs.TRAJECTORIES.items)
        groups(1,i) = segmentation_configs.TRAJECTORIES.items(1,i).group;
    end
    if length(groups) > 1
    % ask which one or two animal groups
        prompt={'Choose one or two animal groups (example: 2 or 1,3)'};
        name = 'Choose groups';
        defaultans = {''};
        options.Interpreter = 'tex';
        user = inputdlg(prompt,name,[1 30],defaultans,options);
        results_strategies_distributions_length(segmentation_configs,classification_configs,user);
    else
    % There is only one group thus take all the animals
        results_strategies_distributions_length(segmentation_configs,classification_configs);
    end  
    
    
function transitions_count_Callback(hObject, eventdata, handles)
    % ask for segmentation_config file
    segmentation_configs = select_files(1);
    if isempty(segmentation_configs)
        return
    end  
    % ask for classification_config file
    classification_configs = select_files(3);
    if isempty(classification_configs)
        return
    end  
    % find available animal groups
    groups = zeros(1,length(segmentation_configs.TRAJECTORIES.items));
    for i = 1:length(segmentation_configs.TRAJECTORIES.items)
        groups(1,i) = segmentation_configs.TRAJECTORIES.items(1,i).group;
    end
    if length(groups) > 1
    % ask which one or two animal groups
        prompt={'Choose one or two animal groups (example: 2 or 1,3)'};
        name = 'Choose groups';
        defaultans = {''};
        options.Interpreter = 'tex';
        user = inputdlg(prompt,name,[1 30],defaultans,options);
        results_transition_counts(segmentation_configs,classification_configs,user);
    else
    % There is only one group thus take all the animals
        results_transition_counts(segmentation_configs,classification_configs);
    end 
    

function transitions_prob_Callback(hObject, eventdata, handles)
    % ask for segmentation_config file
    segmentation_configs = select_files(1);
    if isempty(segmentation_configs)
        return
    end  
    % ask for classification_config file
    classification_configs = select_files(3);
    if isempty(classification_configs)
        return
    end  
    % find available animal groups
    groups = zeros(1,length(segmentation_configs.TRAJECTORIES.items));
    for i = 1:length(segmentation_configs.TRAJECTORIES.items)
        groups(1,i) = segmentation_configs.TRAJECTORIES.items(1,i).group;
    end
    if length(groups) > 1
    % ask which one or two animal groups
        prompt={'Choose one or two animal groups (example: 2 or 1,3)'};
        name = 'Choose groups';
        defaultans = {''};
        options.Interpreter = 'tex';
        user = inputdlg(prompt,name,[1 30],defaultans,options);
        results_strategies_transition_prob(segmentation_configs,classification_configs,user);
    else
    % There is only one group thus take all the animals
        results_strategies_transition_prob(segmentation_configs,classification_configs);
    end 

    
function confusion_matrix_Callback(hObject, eventdata, handles)
    % ask for segmentation_config file
    segmentation_configs = select_files(1);
    if isempty(segmentation_configs)
        return
    end  
    % ask for classification_config file
    classification_configs = select_files(3);
    if isempty(classification_configs)
        return
    end
    results_confusion_matrix(segmentation_configs,classification_configs,10);
