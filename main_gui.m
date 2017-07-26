function varargout = main_gui(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @main_gui_OutputFcn, ...
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

% --- Executes just before main_gui is made visible.
function main_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % Initialize
    [main_path] = initialization;
    set(handles.new_project,'UserData',{main_path});
    set(handles.conf_tags,'Enable','off');
    set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'off');
    set(handles.res_demo,'Enable','on');
    set(handles.paths_features,'Enable','off');
    set(handles.res_compare_class,'Visible','off');
    set(handles.classification_conf,'UserData',[0,100,0,25,40,0]);
    set(handles.paths_features,'Visible','off');
    % Choose default command line output for main_gui
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes main_gui wait for user response (see UIRESUME)
    % uiwait(handles.main_figure);
    % --- Outputs from this function are returned to the command line.
function varargout = main_gui_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
function main_figure_CloseRequestFcn(hObject, eventdata, handles)
    delete(hObject);

%%%% PROJECT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_project_Callback(hObject, eventdata, handles)
    exe_new_project(hObject, eventdata, handles);  
    paths_features_Callback(hObject, eventdata, handles);
    %pick default segmentation, labels, classification
    refresh_seg_Callback(hObject, eventdata, handles);
    refresh_labs_Callback(hObject, eventdata, handles);
    refresh_class_Callback(hObject, eventdata, handles);      
    
function load_project_Callback(hObject, eventdata, handles)
    exe_load_project(hObject, eventdata, handles);
    %in case the project was created using the old version generate the
    %extra files
    project_path = get(handles.load_project,'UserData');
    project_path = char_project_path(project_path);
    if ~exist(fullfile(project_path,'settings','my_trajectories_features.mat'))
        paths_features_Callback(hObject, eventdata, handles);
    end
    %pick default segmentation, labels, classification
    refresh_seg_Callback(hObject, eventdata, handles);
    refresh_labs_Callback(hObject, eventdata, handles);
    refresh_class_Callback(hObject, eventdata, handles);
    
function paths_features_Callback(hObject, eventdata, handles)  
    %EXECUTE AFTER NEW PROJECT
    project_path = get(handles.load_project,'UserData');
    project_path = char_project_path(project_path); 
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end   
    [temp, idx] = hide_gui('RODA');
    error = full_trajectory_features(project_path);
    set(temp(idx),'Visible','on'); 
    if ~error
        msgbox('Operation successfully completed','Success');
    end   
    
%%%% SEGMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function segmentation_button_Callback(hObject, eventdata, handles)
    exe_segmentation(hObject, eventdata, handles);
    refresh_seg_Callback(hObject, eventdata, handles);

function refresh_seg_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    [segmentations,~,~] = pick_defaults(project_path);
    set(handles.default_segmentation,'String',segmentations);
    set(handles.default_segmentation,'Value',1);

%%%% LABELLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browse_trajectories_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    %hide this GUI
    [temp, idx] = hide_gui('RODA');
    if ~iscell(project_path)
        project_path = {project_path};
    end    
    browse(project_path);
    set(temp(idx),'Visible','on');
    refresh_labs_Callback(hObject, eventdata, handles);

function check_labels_Callback(hObject, eventdata, handles)
    exe_check_labels(hObject, eventdata, handles);

function refresh_labs_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    [~,labels,~] = pick_defaults(project_path);
    set(handles.default_labels,'String',labels);
    set(handles.default_labels,'Value',1);

%%%% CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function default_classification_Callback(hObject, eventdata, handles)
    exe_default_classification(hObject, eventdata, handles);
    refresh_class_Callback(hObject, eventdata, handles);    

function advanced_classification_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    [temp, idx] = hide_gui('RODA');
    classification_adv(project_path);
    set(temp(idx),'Visible','on');
    refresh_class_Callback(hObject, eventdata, handles)
    
function refresh_class_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    [~,~,class] = pick_defaults(project_path);
    set(handles.default_class,'String',class);
    set(handles.default_class,'Value',1);

%%%% RESULT BUTTONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res_demo_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    demo_gui;
    set(temp(idx),'Visible','on');
    
function res_metrics_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end    
    
function res_strategies_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end
    
function res_transitions_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on'); 
    if ~error
        msgbox('Operation successfully completed','Success');
    end   
    
function res_probabilities_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end     
    
function res_statistics_Callback(hObject, eventdata, handles)
    project_path = char_project_path(get(handles.load_project,'UserData'));
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    class_name = get(handles.default_class,'String');
    idx = get(handles.default_class,'Value');
    class_name = class_name{idx};
    if isempty(class_name)
        errordlg('No classification is selected','Error');
        return;
    end
    [temp, idx] = hide_gui('RODA');
    %post or pre smoothing?
    choice = questdlg('Would you like to generate the statistics before or after applying the smoothing function?', ...
        'Statistics','Before','After','Cancel','Before');
    switch choice
        case 'Before'
            [error,~,~] = class_statistics(project_path, class_name);
        case 'After'
            try
                tmp = strsplit(class_name,'_');
                tmp = strcat('segmentation_configs_',tmp{3},'_',tmp{4},'_',tmp{5},'.mat');
                load(fullfile(project_path,'segmentation',tmp));
            catch
                errordlg('Cannot load segmentation object');
                set(temp(idx),'Visible','on'); 
                return
            end
            [error,~,~] = class_statistics(project_path, class_name, 'SEGMENTATION', segmentation_configs);
        case 'Cancel'
            error = 1;
        otherwise
            error = 1;
    end    
    set(temp(idx),'Visible','on'); 
    if ~error
        msgbox('Operation successfully completed','Success');
    end  
    
function res_compare_class_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    [temp, idx] = hide_gui('RODA');
    gui_compare(project_path);
    set(temp(idx),'Visible','on');    
    
%%%% MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function options_tab_Callback(hObject, eventdata, handles)

function conf_figs_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    figure_configs;
    set(temp(idx),'Visible','on');

function conf_tags_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    [temp, idx] = hide_gui('RODA');
    tags_config(project_path);
    set(temp(idx),'Visible','on');    
    
% --------------------------------------------------------------------    
function advanced_tab_Callback(hObject, eventdata, handles)

function method_conf_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    ret = get(handles.method_conf,'UserData');
    %[ STR_DISTR, TRANS_DISTR, SIGMA, INTERVAL, R_SIGMA, R_INTERVAL ]
    ret = advanced_gui(ret); 
    set(handles.method_conf,'UserData',ret);
    set(temp(idx),'Visible','on');  

function features_conf_Callback(hObject, eventdata, handles)
    features_config;

function classification_conf_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('RODA');
    ret = get(handles.classification_conf,'UserData');
    %[ STOP_ERROR, STOP_K, PICK_Start, PICK_END, N_CLASS, START_K ]
    ret = classification_configs_adv(ret);
    set(handles.classification_conf,'UserData',ret);
    set(temp(idx),'Visible','on');      



%%%% AUTO-GEN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
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
function default_segmentation_Callback(hObject, eventdata, handles)
function default_segmentation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
     
function default_labels_Callback(hObject, eventdata, handles)
function default_labels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function default_class_Callback(hObject, eventdata, handles)
function default_class_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


