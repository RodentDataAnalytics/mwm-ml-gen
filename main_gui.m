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
    set(handles.config_tags,'Enable','off');
    set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'off');
    set(handles.res_demo,'Enable','on');
    set(handles.config_tags,'Visible','off');
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
            tags_path = fullfile(ctfroot,'configs','tags','tags.txt');
        else
            tags_path =  fullfile(pwd,'configs','tags','tags.txt');      
        end   
        copyfile(tags_path,fullfile(project_path,'settings'));
        %resume this GUI's visibility
        set(temp(idx),'Visible','on'); 
        %activate everything
        set(handles.config_tags,'Enable','on');
        set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'on');
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
    %activate everything
    set(handles.config_tags,'Enable','on');
    set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'on');
    %pick default segmentation, labels, classification
    refresh_seg_Callback(hObject, eventdata, handles);
    refresh_labs_Callback(hObject, eventdata, handles);
    refresh_class_Callback(hObject, eventdata, handles);
    
function config_tags_Callback(hObject, eventdata, handles)   
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    if iscell(project_path)
        project_path = char(project_path{1});
    end
    % config tags GUI
    tags_config;
    % read the new tags
    contents_new = parse_tags;
    % check the project tags
    if isdeployed
        tags_path = fullfile(project_path,'settings','tags.txt');
    else
        tags_path =  fullfile(project_path,'settings','tags.txt');      
    end  
    contents_old = parse_tags(tags_path);
    % check if abbreviation/name/id/weight has changed
    if ~isequal(contents_new(:,1:4),contents_old(:,1:4))
        % see if we have classifications or results
        class = dir(fullfile(project_path,'classification'));
        mclass = dir(fullfile(project_path,'Mclassification'));
        res = dir(fullfile(project_path,'results'));
        % if we do create a new project
        if ~isempty(class) > 2 || ~isempty(mclass) > 2 || length(res) > 2
            % keep a copy of settings
            settings = fullfile(project_path,'settings');
            segmentation = fullfile(project_path,'segmentation');
            labels = fullfile(project_path,'labels');
            % new project
            msgbox('A new project needs to be created with the new tags. Specify project''s path and name');
            main_path = fileparts(project_path);
            project_path = set_project({main_path});
            % if close is pressed take back the old tags
            if isempty(project_path)
                if ~isdeployed
                    copyfile(tags_path,fullfile(pwd,'configs','tags','tags.txt'));
                else
                    copyfile(tags_path,fullfile(ctfroot,'configs','tags','tags.txt'));
                end
                return
            else
                % copy the project to the new project
                copyfile(settings,fullfile(project_path,'settings'),'f');
                copyfile(segmentation,fullfile(project_path,'segmentation'),'f');
                copyfile(labels,fullfile(project_path,'labels'),'f');
                % delete all the mat from labels so that the user has to
                % reload and fix them
                delete(fullfile(project_path,'labels','*.mat'));
                % copy the tags.txt also from the program path
                if ~isdeployed
                    tags_path = fullfile(pwd,'configs','tags','tags.txt');
                else
                    tags_path = fullfile(ctfroot,'configs','tags','tags.txt');
                end  
                copyfile(tags_path,fullfile(project_path,'settings'),'f');
                set(handles.load_project,'UserData',project_path);
            end
        end
    end
    % if only the color or the linetype is changed keep the same project    
    if isdeployed
        tags_path = fullfile(ctfroot,'configs','tags','tags.txt');
    else
        tags_path =  fullfile(pwd,'configs','tags','tags.txt');      
    end   
    copyfile(tags_path,fullfile(project_path,'settings'),'f');
    %pick default segmentation, labels, classification
    refresh_seg_Callback(hObject, eventdata, handles);
    refresh_labs_Callback(hObject, eventdata, handles);
    refresh_class_Callback(hObject, eventdata, handles);

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

%%%% LABELLING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browse_trajectories_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    %hide this GUI
    [temp, idx] = hide_gui('MWM-ML');
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
    % Run the cross-validation process
    [temp, idx] = hide_gui('MWM-ML');
    p = strsplit(lab_name,'.mat');
    p = p{1};
    output_path = char(fullfile(project_path,'labels',strcat(p,'_check')));
    if ~exist(output_path,'dir')
        mkdir(output_path);
    else
        choice = questdlg('Checking has already been performed would you like to rerun it?','Cross-validation','No','Yes','No');
        if isequal(choice,'No')
            return;
        else
            rmdir(output_path,'s');
            mkdir(output_path); 
        end
    end
    [nc,res1bare,res2bare,res1,res2,res3,covering] = results_clustering_parameters(segmentation_configs,labels,0,output_path);
    output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation')));
    if exist(output_path,'dir');
        rmdir(output_path,'s');
    end
    mkdir(output_path);
    [nc,per_errors1,per_undefined1,coverage] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
    results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering);
    row = {'Clusters','Error(%)','Undefined(%)','Coverage(%)'};
    table = [nc;per_errors1;per_undefined1;coverage];
    table = table';
    table = num2cell(table);
    table = [row;table];
    table = cell2table(table);
    fpath = fullfile(output_path,'cross_validation.csv');
    try
        fid = fopen(fpath,'w');
        fclose(fid);      
        % save the labels to the file
        writetable(table,fpath,'WriteVariableNames',0);
        error = 0;
    catch
        error = 1;
    end    
    if error
        errordlg('Cannot generate cross-validation file');
    end
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

%%%% CLASSIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function default_classification_Callback(hObject, eventdata, handles)
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
function similarity_check_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return;
    end
    [temp, idx] = hide_gui('MWM-ML');
    gui_similarity(project_path);
    set(temp(idx),'Visible','on');
function default_class_Callback(hObject, eventdata, handles)
function default_class_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function refresh_class_Callback(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    [~,~,class] = pick_defaults(project_path);
    set(handles.default_class,'String',class);

%%%% RESULT BUTTONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res_demo_Callback(hObject, eventdata, handles)
    demo(1);
    
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

function res_probabilities_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    error = gui_generate_results(handles,eventdata);
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end     

%%%% MENU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function options_tab_Callback(hObject, eventdata, handles)
function conf_figs_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('MWM-ML');
    figure_configs;
    set(temp(idx),'Visible','on');

