function varargout = browse_trajectories(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @browse_trajectories_OpeningFcn, ...
                   'gui_OutputFcn',  @browse_trajectories_OutputFcn, ...
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GUI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before gui is made visible.
function browse_trajectories_OpeningFcn(hObject, eventdata, handles, varargin)
    % Assign paths and initialize WIKA
    initializer;
    % load tags specified in "tags_list.m"
    tags = tags_list;
    set(handles.tag_drop,'UserData',tags);
    tag_names = cell(1,length(tags));
    for i=1:length(tags)
        tag_names{i} = tags{1,i}{1,1};
    end
    set(handles.tag_drop,'String',tag_names);
    % load features specified in "features_list.m"
    features = features_list;
    features_names = cell(1,length(features));
    for i=1:length(features_names)
        features_names{i} = features{1,i}{1,1};
    end
    set(handles.seg_info,'RowName',['#','Offset',features_names]);
    % Choose default command line output for gui
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    
% --- Outputs from this function are returned to the command line.
function varargout = browse_trajectories_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% BUTTON: SELECT CONFIGURATION FILE %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function select_file_Callback(hObject, eventdata, handles)   
    % load the file and check if it the file is correct
    error = 1;
    while error
        [FN_group,PN_group] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select a segmentation configuration file');
        if PN_group == 0
            return;
        end 
        load(strcat(PN_group,FN_group));
        if exist('segmentation_configs')
            if isa(segmentation_configs,'config_segments')
                error=0;
            end
        end
    end
    % plot the arena
    plot_arena(segmentation_configs);
    % plot the first trajectory
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,1));
    set(handles.specific_id,'String',1);
    % fill the table for the trajectory
    set(handles.traj_info,'data',table_trajectory(segmentation_configs,1));
    % fill the segments list 
    segs = find_segs_of_traj( segmentation_configs.SEGMENTS, 1 );
    list_data = cell(1,length(segs)+1);
    list_data{1} = 'Trajectory';
    for i=1:length(segs)
        list_data{i+1} = strcat('seg_',num2str(i)); 
    end
    set(handles.seg_list,'String',list_data);
    % save the configs inside the UserData
    set(handles.select_file, 'UserData', segmentation_configs);
    
 
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% BUTTON: LOAD LABELS FILE %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function labels_file_Callback(hObject, eventdata, handles)
    [FN_labels,PN_labels] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels');
    if PN_labels == 0
        return;
    end 
    labels_path = strcat(PN_labels,FN_labels);
    segmentation_configs = get(handles.select_file,'UserData');
    if ~isempty(segmentation_configs);
        %First remove existing labels
        for i = 1:length(segmentation_configs.SEGMENTS.items)
            segmentation_configs.SEGMENTS.items(1,i).tags = {};
        end    
        % then load the new labels
        segmentation_configs = gui_setup_tags(segmentation_configs,labels_path);
        set(handles.select_file, 'UserData', segmentation_configs);
    else
        errordlg('No segmentation_configs file loaded.');
        return;
    end
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BUTTON: SAVE LABELS  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

function save_labels_Callback(hObject, eventdata, handles) 
    % propose file name and create file
    time = fix(clock);
    formatOut = 'yyyy-mmm-dd-HH-MM';
    time = datestr((time),formatOut);
    [file,path] = uiputfile('*.csv','Save segments labels',strcat('labels_',time));
    fid = fopen(strcat(path,file),'w');
    segmentation_configs = get(handles.select_file,'UserData');
    % configure the data for saving
    t = {};
    for i = 1:length(segmentation_configs.SEGMENTS.items)
        k = 1;
        if length(segmentation_configs.SEGMENTS.items(1,i).tags) > 0
            for j = 1:length(segmentation_configs.SEGMENTS.items(1,i).tags)
                t{1,k} = segmentation_configs.SEGMENTS.items(1,i).tags{1,j}{1,1};
                k=k+1;
            end
            fprintf(fid, '%s,', num2str(i));
            for index = 1:length(t)
                fprintf(fid, '%s,', t{1,index});
            end    
            fprintf(fid, '\n');
        end    
    end 
    fclose(fid);
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SEGMENTS LIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function seg_list_Callback(hObject, eventdata, handles)
    % get the segments
    segmentation_configs = get(handles.select_file,'UserData');
    % get trajectory
    traj = str2num(get(handles.specific_id,'String'));
    % get segments of the trajectory
    segs = find_segs_of_traj( segmentation_configs.SEGMENTS, traj );
    % get selected segment
    index = get(handles.seg_list,'Value');
    % check if specific_id text is correct
    idx = get(handles.specific_id,'String');
    if isempty(str2num(idx))
        return
    end    
    if index ~= 1
        index = index-1; % because the first index = ''
        % Segment info
        segment = segmentation_configs.SEGMENTS.items(1,segs(1,index));
        segment_features = segmentation_configs.FEATURES_VALUES_SEGMENTS(segs(1,index),:);
        segment_data = [segs(1,index) , segment.offset , segment_features];
        set(handles.seg_info,'data',segment_data');
        % Segment labels
        tags = cell(1,length(segment.tags));
        for i=1:length(segment.tags)
            tags{i} = segment.tags{1,i}{1,1};
        end
        set(handles.tags_box,'String',strjoin(tags));
        % Draw the segment on the plotter
        plot_arena(segmentation_configs);
        plot_segment(segment);     
    else
        %segment_data = cell(1,length(handles.seg_info.Data));
        segment_data = cell(1,length(get(handles.seg_info,'Data')));
        for i = 1:length(segment_data)
            segment_data{i} = '';
        end    
        set(handles.seg_info,'data',segment_data');
        set(handles.tags_box,'String','');
        plot_arena(segmentation_configs);
        plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,str2num(idx)));        
    end

    
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BUTTON ADD TAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
function add_tag_Callback(hObject, eventdata, handles)
    % get the segments
    segmentation_configs = get(handles.select_file,'UserData');
    % get the tags
    full_tags = get(handles.tag_drop,'UserData');
    % get the text on the tag list as string
    str = get(handles.tags_box, 'String');
    % get the # of the segment
    seg_num = get(handles.seg_info, 'data');
    if strcmp(seg_num(1),{''}) || iscell(seg_num(1))
        return;
    end    
    seg_num = seg_num(1);
    % get the value of the droplist
    contents = get(handles.tag_drop,'String'); 
    tag_dropValue = contents{get(handles.tag_drop,'Value')};
    % find which tag we have in the droplist
    for i=1:length(full_tags)
        if strcmp(full_tags{1,i}{1,1},tag_dropValue);
            tag_idx = i;
        end    
    end    
    % split the string to distinguish each tag
    if iscell(str)
        tags = strsplit(cell2mat(str));
    else
        tags = strsplit(str);
    end
    % if the string wasn't empty
    if ~strcmp(tags{1,1},'')
        %find if already have this tag and ifwe do return
        for i=1:length(tags)
            if strcmp(tags{1,i},tag_dropValue)
                return;
            end
        end
        % if we do not have it, update the gui
        new_srt = strcat(str,{' '},tag_dropValue);
        set(handles.tags_box, 'String',new_srt);
        len = length(segmentation_configs.SEGMENTS.items(1,seg_num).tags);
        segmentation_configs.SEGMENTS.items(1,seg_num).tags(1,len+1) = full_tags(1,tag_idx);
        set(handles.select_file, 'UserData', segmentation_configs);
    % if the string was empty, update the gui 
    else
        set(handles.tags_box, 'String',tag_dropValue);
        segmentation_configs.SEGMENTS.items(1,seg_num).tags = full_tags(1,tag_idx);
        set(handles.select_file, 'UserData', segmentation_configs);
    end  
 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% BUTTON REMOVE TAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

function remove_tag_Callback(hObject, eventdata, handles)
    % get the segments
    segmentation_configs = get(handles.select_file,'UserData');
    % get the tags
    full_tags = get(handles.tag_drop,'UserData');
    % get the text on the tag list as string
    str = get(handles.tags_box, 'String');
    % get the # of the segment
    seg_num = get(handles.seg_info, 'data');
    if strcmp(seg_num(1),{''}) || iscell(seg_num(1))
        return;
    end    
    seg_num = seg_num(1);
    % get the value of the droplist
    contents = get(handles.tag_drop,'String'); 
    tag_dropValue = contents{get(handles.tag_drop,'Value')};
    % split the string to distinguish each tag
    if iscell(str)
        tags = strsplit(cell2mat(str));
    else
        tags = strsplit(str);
    end
    % if the string wasn't empty
    if ~strcmp(tags{1,1},'')
        % if we have it, update the gui
        new_srt = strrep(str,tag_dropValue,{''});
        new_srt = regexprep(new_srt,' +',' '); % removes double gaps
        set(handles.tags_box, 'String',new_srt);
        len = length(segmentation_configs.SEGMENTS.items(1,seg_num).tags);
        flag = 1;
        for i=1:len
            if strcmp(segmentation_configs.SEGMENTS.items(1,seg_num).tags{1,i}{1,1},tag_dropValue);
                seg_idx = i;
                flag = 0;
                break;
            end
        end 
        % if we don't have it return 
        if flag
            return
        end    
        % remove it
        segmentation_configs.SEGMENTS.items(1,seg_num).tags{1,seg_idx}={};
        % bring the last tag to the empty slot
        if len > 1
            segmentation_configs.SEGMENTS.items(1,seg_num).tags{1,seg_idx} = segmentation_configs.SEGMENTS.items(1,seg_num).tags{1,len};
            segmentation_configs.SEGMENTS.items(1,seg_num).tags = segmentation_configs.SEGMENTS.items(1,seg_num).tags(1,1:end-1);
        end
        set(handles.select_file, 'UserData', segmentation_configs);
    % if the string was empty, do nothing
    else
        return;
    end  
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotter_CreateFcn(hObject, eventdata, handles)     
    axis off;
function traj_previous_Callback(hObject, eventdata, handles)
    segmentation_configs = get(handles.select_file,'UserData');
    idx = get(handles.specific_id,'String');
    if isempty(str2num(idx))
    	return
    end  
    if str2num(idx) == 1 ||  str2num(idx) <= 0 || str2num(idx) > length(segmentation_configs.TRAJECTORIES.items)
        return
    end
    % update pointer
    set(handles.specific_id,'String',num2str(str2num(idx)-1));
    idx = get(handles.specific_id,'String');
    % plot the arena
    plot_arena(segmentation_configs);
    % plot the previous trajectory
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,str2num(idx)));
    % fill the table for the trajectory
    set(handles.traj_info,'data',table_trajectory(segmentation_configs,str2num(idx))); 
    % fill the segments list 
    segs = find_segs_of_traj(segmentation_configs.SEGMENTS, str2num(idx));
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
        set(handles.seg_list,'String',list_data);  
    else
        list_data{1} = 'Trajectory';
        set(handles.seg_list,'String',list_data);
        set(handles.seg_info,'data','');
    end    
function traj_next_Callback(hObject, eventdata, handles)
    segmentation_configs = get(handles.select_file,'UserData');
    idx = get(handles.specific_id,'String');
    if isempty(str2num(idx))
    	return
    end  
    if str2num(idx) >= length(segmentation_configs.TRAJECTORIES.items) || str2num(idx) <= 0
        return
    end
    % update pointer
    set(handles.specific_id,'String',num2str(str2num(idx)+1));
    idx = get(handles.specific_id,'String');
    % plot the arena
    plot_arena(segmentation_configs);
    % plot the next trajectory
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,str2num(idx)));
    % fill the table for the trajectory
    set(handles.traj_info,'data',table_trajectory(segmentation_configs,str2num(idx))); 
    % fill the segments list 
    segs = find_segs_of_traj(segmentation_configs.SEGMENTS, str2num(idx));
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
        set(handles.seg_list,'String',list_data);  
    else
        list_data{1} = 'Trajectory';
        set(handles.seg_list,'String',list_data);
        set(handles.seg_info,'data','');
    end    
function id_ok_Callback(hObject, eventdata, handles)
    segmentation_configs = get(handles.select_file,'UserData');
    idx = get(handles.specific_id,'String');
    if isempty(str2num(idx))
    	return
    end    
    if str2num(idx) > length(segmentation_configs.TRAJECTORIES.items) || str2num(idx) <= 0
        return
    end
    % update pointer
    set(handles.specific_id,'String',num2str(str2num(idx)));
    % plot the arena
    plot_arena(segmentation_configs);
    % plot the next trajectory
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,str2num(idx)));
    % fill the table for the trajectory
    set(handles.traj_info,'data',table_trajectory(segmentation_configs,str2num(idx))); 
        % fill the segments list 
    segs = find_segs_of_traj(segmentation_configs.SEGMENTS, str2num(idx));
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
        set(handles.seg_list,'String',list_data);  
    else
        list_data{1} = 'Trajectory';
        set(handles.seg_list,'String',list_data);
        set(handles.seg_info,'data','');
    end    



