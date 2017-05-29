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
    main_path = get(handles.new_project,'UserData');
    %set project name and folder
    project_path = set_project(main_path);
    if isempty(project_path)
        return;
    else
        %hide this GUI
        [temp, idx] = hide_gui('MWM-ML');
        set(handles.load_project,'UserData',project_path);
        %load the new project
        if ~iscell(project_path) 
            project_path = {project_path};
        end
        new_project(project_path);
        project_path = char_project_path(project_path);
        files  = dir(fullfile(project_path,'settings','*.mat'));
        if isempty(files) % no data were loaded
            rmdir(project_path,'s');
            set(temp(idx),'Visible','on'); 
            return
        end
        if isdeployed
            tags_path = fullfile(ctfroot,'configs','tags','tags_default.txt');
            tags_path2 = fullfile(ctfroot,'configs','tags','tags.txt');
        else
            tags_path =  fullfile(pwd,'configs','tags','tags_default.txt'); 
            tags_path2 = fullfile(pwd,'configs','tags','tags.txt');
        end   
        copyfile(tags_path,fullfile(project_path,'settings'));
        copyfile(tags_path2,fullfile(project_path,'settings'))
        %resume this GUI's visibility
        set(temp(idx),'Visible','on'); 
        %activate everything
        set(handles.conf_tags,'Enable','on');
        set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'on');
        set(handles.paths_features,'Enable','on');
        %pick default segmentation, labels, classification
        refresh_seg_Callback(hObject, eventdata, handles);
        refresh_labs_Callback(hObject, eventdata, handles);
        refresh_class_Callback(hObject, eventdata, handles);
    end
        
function load_project_Callback(hObject, eventdata, handles)
    main_path = get(handles.new_project,'UserData');
    [~,ppath] = uigetfile({'*.cfg','CONFIG-file (*.cfg)'},'Select configuration file',main_path{1});
    if isequal(ppath,0)
        return
    end
    set(handles.load_project,'UserData',{ppath});
    %check if we have the tags
    tpath1 = fullfile(ppath,'settings','tags_default.txt');
    tpath2 = fullfile(ppath,'settings','tags.txt');
    if ~exist(tpath1,'file') || ~exist(tpath2,'file')
        if isdeployed
            tags_path = fullfile(ctfroot,'configs','tags','tags_default.txt');
            tags_path2 = fullfile(ctfroot,'configs','tags','tags.txt');
        else
            tags_path =  fullfile(pwd,'configs','tags','tags_default.txt'); 
            tags_path2 = fullfile(pwd,'configs','tags','tags.txt');
        end   
        copyfile(tags_path,fullfile(ppath,'settings'));
        copyfile(tags_path2,fullfile(ppath,'settings'))        
    end
    %activate everything
    set(handles.conf_tags,'Enable','on');
    set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'on');
    set(handles.paths_features,'Enable','on');
    %pick default segmentation, labels, classification
    refresh_seg_Callback(hObject, eventdata, handles);
    refresh_labs_Callback(hObject, eventdata, handles);
    refresh_class_Callback(hObject, eventdata, handles);
    
function paths_features_Callback(hObject, eventdata, handles)  
    project_path = get(handles.load_project,'UserData');
    project_path = char_project_path(project_path); 
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end   
    [temp, idx] = hide_gui('MWM-ML');
    error = full_trajectory_features(project_path);
    set(temp(idx),'Visible','on'); 
    if ~error
        msgbox('Operation successfully completed','Success');
    end   
%%%% SEGMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
function segmentation_button_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end    
    seg_length = get(handles.seg_length,'String');
    seg_overlap = get(handles.seg_overlap,'String');
    error = check_segmentation_properties(seg_length,seg_overlap);
    if error
        return;
    end
    seg_length = str2double(seg_length);
    seg_overlap = unique(str2num(seg_overlap));
    [temp, idx] = hide_gui('MWM-ML');
    error = execute_segmentation(project_path,seg_length,seg_overlap);
    set(temp(idx),'Visible','on'); 
    refresh_seg_Callback(hObject, eventdata, handles);
    if ~error
        msgbox('Operation successfully completed','Success');
    end
function default_segmentation_Callback(hObject, eventdata, handles)
function default_segmentation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
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
    [temp, idx] = hide_gui('MWM-ML');
    if ~iscell(project_path)
        project_path = {project_path};
    end    
    browse(project_path);
    set(temp(idx),'Visible','on');
    refresh_labs_Callback(hObject, eventdata, handles);
function check_labels_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    % Load segmentation_config and labels
    seg_name = get(handles.default_segmentation,'String');
    idx = get(handles.default_segmentation,'Value');
    seg_name = seg_name{idx};
    lab_name = get(handles.default_labels,'String');
    idx = get(handles.default_labels,'Value');
    lab_name = lab_name{idx};
    if isempty(seg_name) || isempty(lab_name)
        errordlg('A segmentation and a labels files need to be selected','Error');
        return;
    end
    labels = char(fullfile(project_path,'labels',lab_name));
    try
        load(labels)
    catch
        errordlg('Cannot load labels file','Error');
        return
    end  
    segs = char(fullfile(project_path,'segmentation',seg_name));
    try
        load(segs)
    catch
        errordlg('Cannot load segmentation file','Error');
        return
    end
    if ~isequal(length(segmentation_configs.SEGMENTS.items),length(LABELLING_MAP))
        errordlg('The selected segmentation do not match with the selected labelling','Error');
        return    
    end
    % Run the cross-validation process
    [temp, idx] = hide_gui('MWM-ML');
    p = strsplit(lab_name,'.mat');
    p = p{1};
    [s,e,step,options] = cross_validation_clusters;
    if e == -1 || s == -1 || step == -1
        return
    end
    output_path = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
    if ~exist(output_path,'dir')
        mkdir(output_path);
    else
        choice = questdlg('Checking has already been performed would you like to rerun it?','Cross-validation','No','Yes','Generate graphs only','Generate graphs only');
        if isequal(choice,'No')
            return;
        elseif isequal(choice,'Yes')
            rmdir(output_path,'s');
            mkdir(output_path); 
        elseif isequal(choice,'Generate graphs only')
        end
    end
    %[nc,res1bare,res2bare,res1,res2,res3,covering] = results_clustering_parameters(segmentation_configs,labels,0,output_path,s,e,step);
    [nc,res1bare,res2bare,res1,res2,res3,covering] = cross_validation(segmentation_configs,labels,10,[s,e,step],output_path,options,0);
    output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation'),options));
    if exist(output_path,'dir');
        rmdir(output_path,'s');
    end
    mkdir(output_path);
    [nc,per_errors1,per_undefined1,coverage] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
    data = [nc', per_errors1', per_undefined1', coverage'];
    % export results to CSV file
    export_num_of_clusters(output_path,data);
    % generate graphs
    results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering);
    set(temp(idx),'Visible','on'); 
    
function default_labels_Callback(hObject, eventdata, handles)
function default_labels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function refresh_labs_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    [~,labels,~] = pick_defaults(project_path);
    set(handles.default_labels,'String',labels);
    set(handles.default_labels,'Value',1);

%%%% CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function default_classification_Callback(hObject, eventdata, handles)
    % Initialization
    [error,project_path,seg_name,lab_name] = initialize_classification(handles,eventdata);
    if isempty(project_path) || error
        return;
    end
    % Hide GUI and execute
    [temp, idx] = hide_gui('MWM-ML');
    error = default_classification(project_path,seg_name,lab_name);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end
    refresh_class_Callback(hObject, eventdata, handles);
    
function advanced_classification_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    [temp, idx] = hide_gui('MWM-ML');
    classification_adv(project_path);
    set(temp(idx),'Visible','on');
    refresh_class_Callback(hObject, eventdata, handles)
function default_class_Callback(hObject, eventdata, handles)
function default_class_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function refresh_class_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    [~,~,class] = pick_defaults(project_path);
    set(handles.default_class,'String',class);
    set(handles.default_class,'Value',1);

%%%% RESULT BUTTONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res_demo_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    demo_gui;
    set(temp(idx),'Visible','on');
    
function res_metrics_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end    
    
function res_strategies_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end
    
function res_transitions_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on'); 
    if ~error
        msgbox('Operation successfully completed','Success');
    end   
    
function res_probabilities_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end     
    
function res_statistics_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
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
    [temp, idx] = hide_gui('MWM-ML');
    [error,~,~] = class_statistics(project_path, class_name);
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
    [temp, idx] = hide_gui('MWM-ML');
    gui_compare(project_path);
    set(temp(idx),'Visible','on');    
    
%%%% MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function options_tab_Callback(hObject, eventdata, handles)

function conf_figs_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    figure_configs;
    set(temp(idx),'Visible','on');
% --------------------------------------------------------------------
function conf_tags_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    [temp, idx] = hide_gui('MWM-ML');
    tags_config(project_path);
    set(temp(idx),'Visible','on');    


% --------------------------------------------------------------------
function advanced_tab_Callback(hObject, eventdata, handles)

function method_conf_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    %[ STR_DISTR, TRANS_DISTR, SIGMA, INTERVAL, R_SIGMA, R_INTERVAL ]
    ret = advanced_gui; 
    set(handles.method_conf,'UserData',ret);
    set(temp(idx),'Visible','on');  
