function varargout = browse(varargin)
%% GUI holds the UserData which are as follows:
% plotter:         mode, 1 or 2
% trajectory_info: segmentation_configs (mode 1)
% segment_info:    classifiation_configs (mode 2)
% tag_box:         user labels, {index,tags} (mode 1)
% available_tags:  list of tags (mode 1)
% browse_data:     holds a default path (if called from another function)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @browse_OpeningFcn, ...
                   'gui_OutputFcn',  @browse_OutputFcn, ...
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


% --- Executes just before browse is made visible.
function browse_OpeningFcn(hObject, eventdata, handles, varargin)
    %load tags and features names
    [tag_names, features_names] = browse_open_function;
%     if tag_names{1} == 0 || features_names{1} == 0
%         disp('Cannot load tags or features');
%         return;
%     end
    %update tables' graphics (NOT WORKING)
%     [ColumnName,RowName,ColumnWidth] = browse_tables_graphics(1);
%     set(handles.trajectory_info,'ColumnName',ColumnName,'RowName',RowName,'ColumnWidth',ColumnWidth);
%     [ColumnName,RowName,ColumnWidth] = browse_tables_graphics(2,features_names);
%     set(handles.segment_info,'ColumnName',ColumnName,'RowName',RowName,'ColumnWidth',ColumnWidth); 
    set(handles.segment_info,'RowName',['#','Offset',features_names]);
    %update the gui
    set(handles.available_tags,'String',tag_names);
    set(handles.available_tags,'UserData',tag_names);
    if ~isempty(varargin)
        set(handles.browse_data,'UserData',varargin{1});  
    end    
    % PLAY OPTIONS + Color + ExportFile UNAVAILABLE (for now)
    set(findall(handles.uibuttongroup1, '-property', 'Visible'), 'Visible', 'off');
    set(handles.color_check, 'Visible', 'off');
    set(handles.track_check, 'Visible', 'off');
    set(handles.export_file, 'Visible', 'off');
    set(handles.track_pop, 'Visible', 'off');
    % Choose default command line output for browse
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes browse wait for user response (see UIRESUME)
    if ~isempty(varargin)
        uiwait(handles.browse_data);
    end
% --- Outputs from this function are returned to the command line.
function varargout = browse_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    % The figure can be deleted now
    if ~isempty(get(handles.browse_data,'UserData'))
        delete(handles.browse_data);
    end
% --- Executes when user attempts to close browse_data.
function browse_data_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.browse_data, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.browse_data);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.browse_data);
    end

%Table
function trajectory_info_CreateFcn(hObject, eventdata, handles)
function segment_info_CreateFcn(hObject, eventdata, handles)

%% ACTIVATION %%
function load_configuration_Callback(hObject, eventdata, handles)
    % load the file and check if it the file is correct
    project_path = get(handles.browse_data,'UserData');
    [ mode, obj ] = browse_activation_function(project_path);
    if mode == 0
        return;
    end
    % run with segmentation configs file
    if mode == 1
        %check and save the file into the UserData
        error = browse_mode_segmentation(obj,handles);
        if error
            errordlg('Error initializing the GUI','Dev Error');
            return
        end    
        set(handles.trajectory_info,'UserData',obj);
        set(handles.plotter,'UserData',mode);
        set(handles.tag_box,'UserData',[]);
    % run with classification configs file    
    elseif mode == 2    
        %check and save the file into the UserData
        %error = browse_mode_classification(obj,handles);
        %if error
        %    errordlg('Error initializing the GUI','Dev Error');
        %    return
        %end
        set(handles.segment_info,'UserData',obj);
        set(handles.plotter,'UserData',mode);
    end    

%% PLOTTING %%
% Plotter
function plotter_CreateFcn(hObject, eventdata, handles)
    axis off;
% Color ON/OFF
function color_check_Callback(hObject, eventdata, handles)
% Show target trajectory
function ok_Callback(hObject, eventdata, handles)
    error = browse_navigation(handles,1);
    if error
        return
    end  
% Show next trajectory
function next_arrow_Callback(hObject, eventdata, handles)
    error = browse_navigation(handles,2);
    if error
        return
    end  
% Show previous trajectory
function previous_arrow_Callback(hObject, eventdata, handles)
    error = browse_navigation(handles,3);
    if error
        return
    end  
% Specifies target trajectory
function navigator_Callback(hObject, eventdata, handles)
function navigator_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% LABELLING %%
% Save labels
function save_Callback(hObject, eventdata, handles)
    error = browse_save_labels(handles);
    if error
        return
    end  
% Load labels
function load_Callback(hObject, eventdata, handles)
    error = browse_load_labels(handles);
    if error
        return
    end  
% Add label
function add_tag_Callback(hObject, eventdata, handles)
    error = browse_add_tag(handles);
    if error
        return
    end  
% Remove label
function remove_tag_Callback(hObject, eventdata, handles)
    error = browse_remove_tag(handles);
    if error
        return
    end  
% Select trajectory/segment
function listbox_Callback(hObject, eventdata, handles)
    browse_select_segment(handles);
function listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Available labels
function available_tags_Callback(hObject, eventdata, handles)
function available_tags_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Segment label(s)
function tag_box_Callback(hObject, eventdata, handles)
function tag_box_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% MOTION %%
function speed_Callback(hObject, eventdata, handles)
function speed_down_Callback(hObject, eventdata, handles)
function speed_up_Callback(hObject, eventdata, handles)
function speed_style_Callback(hObject, eventdata, handles)

%% TRACKING %%
% Activates tracking
function track_check_Callback(hObject, eventdata, handles)
% Show only specified group of segments
function track_pop_Callback(hObject, eventdata, handles)
function track_pop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% EXPORTING %%
% Export currect plot as picture
function export_Callback(hObject, eventdata, handles)
    % get project path
    ppath = get(handles.browse_data,'UserData');  
    ppath = char_project_path(ppath);
    % export format
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % parse UserData
    segmentation_configs = get(handles.trajectory_info,'UserData');
    segs = num2str(size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1));
    % make a folder
    folder = fullfile(ppath,'results',strcat('exported_pics_segmentation_',segs));
    if ~exist(folder,'dir')
        mkdir(folder);
    end
    % generate a new figure
    f = figure;  

    % get trajectory id & check if it is correct
    idx = str2num(get(handles.navigator,'String'));
    if isempty(idx)
        return
    end    
    % get segments of the trajectory
    segs = find_segs_of_traj(segmentation_configs.SEGMENTS, idx);
    % get selected segment
    index = get(handles.listbox,'Value');
    if index == 1 % plot whole trajectory
        % plot the arena
        plot_arena(segmentation_configs);
        % plot the trajectory
        plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,idx));  
        % export the figure
        export_figure(f, folder, strcat('traj',num2str(idx)), Export, ExportStyle);
    else
        index = index-1; % because the first index = 'Trajectory'
        % fill segment table
        segment = segmentation_configs.SEGMENTS.items(1,segs(1,index));
        % plot the segment
        plot_arena(segmentation_configs);
        plot_trajectory(segment,'LineWidth',1.5);  
        % export the figure
        export_figure(f, folder, strcat('traj',num2str(idx),'seg',num2str(index)), Export, ExportStyle);
    end
    delete(f);
    
% Export all segments of specific group as pictures
function export_all_Callback(hObject, eventdata, handles)
    % get project path
    ppath = get(handles.browse_data,'UserData');  
    ppath = char_project_path(ppath);
    % get user labels
    a = get(handles.tag_box,'UserData');
    if isempty(a);
        return
    end
    % export format
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % get selected tag
    all_tags = get(handles.available_tags,'String'); 
    idx = get(handles.available_tags,'Value');        
    selected_tag = all_tags{idx};
    % get segmentation_configs
    segmentation_configs = get(handles.trajectory_info,'UserData');
    % make folder
    segs = num2str(size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1));
    folder = fullfile(ppath,'results',strcat('exported_pics_segmentation_',segs));
    if ~exist(folder,'dir')
        mkdir(folder);
    end
    folder = fullfile(folder,selected_tag);
    if exist(folder,'dir')
        rmdir(folder,'s');
    end  
    mkdir(folder);
    % generate a new figure
    f = figure;
    % start exporting
    for i = 1:length(a{1})
        row = a{2}(i,1:end);
        cells = find(~cellfun(@isempty,row));
        if isequal(selected_tag,'UD')
            if length(cells) > 1 || isequal(row{1},'UD')
                segment = segmentation_configs.SEGMENTS.items(1,a{1}(i));
                % draw the arena and the segment on the new figure
                plot_arena(segmentation_configs);
                plot_trajectory(segment,'LineWidth',1.5); 
                % export the figure
                [traj_id, seg_id] = find_traj_of_seg(segmentation_configs.SEGMENTS, a{1}(i));
                export_figure(f, folder, strcat(selected_tag,'traj',num2str(traj_id),'seg',num2str(seg_id)), Export, ExportStyle);
                % refresh the figure
                clf(f,'reset');
            end
        else
            if isequal(row{1},selected_tag)
                segment = segmentation_configs.SEGMENTS.items(1,a{1}(i));
                % draw the arena and the segment on the new figure
                plot_arena(segmentation_configs);
                plot_trajectory(segment,'LineWidth',1.5); 
                % export the figure
                [traj_id, seg_id] = find_traj_of_seg(segmentation_configs.SEGMENTS, a{1}(i));
                export_figure(f, folder, strcat(selected_tag,'traj',num2str(traj_id),'seg',num2str(seg_id)), Export, ExportStyle);
                % refresh the figure
                clf(f,'reset');
            end
        end
    end
    delete(f);
                   
% Export all segments of specific group to file
function export_file_Callback(hObject, eventdata, handles)
