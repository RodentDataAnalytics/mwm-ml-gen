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
    % Call specific CloseRequestFcn
    set(handles.figure1,'CloseRequestFcn',@closeFig);
    % Choose default command line output for gui
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    
% --- Outputs from this function are returned to the command line.
function varargout = browse_trajectories_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    

% CloseRequestFcn
function closeFig(hObject, eventdata, handles)
    % remove temp csv file
    try
        temp = eventdata.Source.Parent.CallbackObject.CurrentObject.UserData;
        if isempty(temp)
            delete(gcf);
        else
            temp = temp{1,2};
            disp('Deleting temp files...')
            delete(temp);
            disp('Closing...');
            delete(gcf);
        end  
    % in case something is wrong close the figure    
    catch
        warning('Temp file not deleted.');
        delete(gcf);
    end    
    
  

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
    cla
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
    % create a temp file
    temp_file = [tempname '.csv'];
    fid = fopen(temp_file,'w');
    fclose(fid);
    % save the configs inside the UserData
    set(handles.select_file, 'UserData', {segmentation_configs, temp_file});
    
    
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% BUTTON: LOAD LABELS FILE %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function labels_file_Callback(hObject, eventdata, handles)
    % check if the segmentation_configs file is loaded
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end   
    segmentation_configs = temp{1,1};
    temp_file = temp{1,2};
    % ask for labels csv file
    [FN_labels,PN_labels] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels');
    if PN_labels == 0
        return;
    end 
    % check if file is ok
    file = strcat(PN_labels,FN_labels);
    if ~exist(file, 'file') == 2
        errordlg('Error loading the labels file.');
        return
    end     
    % copy file data to temp_file
    [tmp_data,data_indexes] = open_temp_file(file);
    tmp_data = cell2table(tmp_data{1,1});
    writetable(tmp_data,temp_file,'WriteVariableNames',0);  
    % update the UserData
    set(handles.select_file, 'UserData', {segmentation_configs,temp_file});

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% BUTTON: SAVE LABELS  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

function save_labels_Callback(hObject, eventdata, handles) 
    % check if the segmentation_configs file and the labels file are loaded
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end  
    temp_file = temp{1,2};
    % read the temp csv
    fid = fopen(temp_file);
    f_line = fgetl(fid);
    fclose(fid);
    num_cols = length(find(f_line==','))+1;
    fmt = repmat('%s ',[1,num_cols]);
    fid = fopen(temp_file);
    tmp_data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
    fclose(fid);
    % propose file name and create file
    time = fix(clock);
    formatOut = 'yyyy-mmm-dd-HH-MM';
    time = datestr((time),formatOut);
    [file,path] = uiputfile('*.csv','Save segments labels',strcat('labels_',time));
    fid = fopen(strcat(path,file),'w');
    fclose(fid);      
    % save to the new csv file the tmp_data
    tmp_data2 = cell2table(tmp_data{1,1});
    writetable(tmp_data2,strcat(path,file),'WriteVariableNames',0);


    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SEGMENTS LIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function seg_list_Callback(hObject, eventdata, handles)
    % get the segments
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        return
    end    
    segmentation_configs = temp{1,1};
    % get the labels
    [tmp_data,data_indexes] = open_temp_file(temp{1,2});
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
        index = index-1; % because the first index = 'Trajectory'
        % Segment info
        segment = segmentation_configs.SEGMENTS.items(1,segs(1,index));
        segment_features = segmentation_configs.FEATURES_VALUES_SEGMENTS(segs(1,index),:);
        segment_data = [segs(1,index) , segment.offset , segment_features];
        set(handles.seg_info,'data',segment_data');
        % Segment tag(s)
        pos = find(data_indexes==segs(1,index)); % hold position of the seg in file
        tags = '';
        % get the tags if exist
        if ~isempty(pos)
            i = 2;
            k = 1;
            while i<=length(tmp_data{1,1}(pos,:)) &&  ~isequal(tmp_data{1,1}{pos,i},'');
                tags{k} = tmp_data{1,1}{pos,i};
                k = k+1;
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        end    
        set(handles.tags_box,'String',tags);
        % Draw the segment on the plotter
        plot_arena(segmentation_configs);
        plot_segment(segment);     
    else
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
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end
    % If the trajectory is selected return
    if get(handles.seg_list,'Value') == 1;
        return
    end    
    segmentation_configs = temp{1,1};
    % get the labels
    [tmp_data,data_indexes] = open_temp_file(temp{1,2});
    % get the text of the tag box as string
    str = get(handles.tags_box, 'String');
    % get the # of the segment
    seg_num = get(handles.seg_info, 'data');
    if strcmp(seg_num(1),{''})
        return;
    end    
    seg_num = seg_num(1);
    % get the value of the pop-up list
    contents = get(handles.tag_drop,'String'); 
    tag_dropValue = contents{get(handles.tag_drop,'Value')};
    % split the string to distinguish each tag
    if iscell(str)
        tags = strsplit(cell2mat(str));
    else
        tags = strsplit(str);
    end
    % if the tag box wasn't empty
    if ~strcmp(tags{1,1},'')
        %find if we already have this tag and if we do return
        for i=1:length(tags)
            if strcmp(tags{1,i},tag_dropValue)
                return;
            end
        end
        % if we do not have it, update the gui
        % a) update the tags_box
        new_str = strcat(str,{' '},tag_dropValue);
        set(handles.tags_box, 'String',new_str);
        % b) update the temp csv file
        update_temp_file_add(data_indexes,seg_num,new_str,tmp_data,tag_dropValue,temp{1,2});
        % c) update the UserData
        set(handles.select_file, 'UserData', {segmentation_configs,temp{1,2}});            
    % if the tag box was empty, update the gui 
    else
        % a) update the tags_box
        set(handles.tags_box, 'String',tag_dropValue);
        % b) update the temp csv file
        new_str = tag_dropValue;
        update_temp_file_add(data_indexes,seg_num,new_str,tmp_data,tag_dropValue,temp{1,2});
        % c) update the UserData
        set(handles.select_file, 'UserData', {segmentation_configs,temp{1,2}}); 
    end  
    
 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% BUTTON REMOVE TAG %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

function remove_tag_Callback(hObject, eventdata, handles)
    % get the segments
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end
    % If the trajectory is selected return
    if get(handles.seg_list,'Value') == 1;
        return
    end 
    segmentation_configs = temp{1,1};
    % get the labels
    [tmp_data,data_indexes] = open_temp_file(temp{1,2});
    % get the text of the tag box as string
    str = get(handles.tags_box, 'String');
    % get the # of the segment
    seg_num = get(handles.seg_info, 'data');
    if strcmp(seg_num(1),{''})
        return;
    end    
    seg_num = seg_num(1);
    % get the value of the pop-up list
    contents = get(handles.tag_drop,'String'); 
    tag_dropValue = contents{get(handles.tag_drop,'Value')};
    % split the string to distinguish each tag
    if iscell(str)
        tags = strsplit(cell2mat(str));
    else
        tags = strsplit(str);
    end
    % if the tag box wasn't empty
    if ~strcmp(tags{1,1},'')
        % if we do not have it, return
        flag = 1;
        for i=1:length(tags)
            if strcmp(tags{1,i},tag_dropValue)
                flag = 0;
                break;
            end
        end
        if flag == 1
            return
        end    
        % if we have it, update the gui
        % a) update the tags_box
        new_str = strrep(str,tag_dropValue,{''});
        new_str = regexprep(new_str,' +',' '); % removes double gaps
        set(handles.tags_box, 'String',new_str);
        % b) update the temp csv file
        update_temp_file_remove(data_indexes,seg_num,new_str,tmp_data,temp{1,2});
        % c) update the UserData
        set(handles.select_file, 'UserData', {segmentation_configs,temp{1,2}});         
    % if the tag box was empty, do nothing
    else
        return;
    end  
    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotter_CreateFcn(hObject, eventdata, handles)     
    axis off;
function traj_previous_Callback(hObject, eventdata, handles)
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end    
    segmentation_configs = temp{1,1};
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
    % if the trajectory has segments
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
        set(handles.seg_list,'Value',1); %select the first value
        set(handles.seg_list,'String',list_data);
    % if the trajectory has no segments    
    else 
        list_data{1} = 'Trajectory';
        set(handles.seg_list,'Value',1); %select the first value
        set(handles.seg_list,'String',list_data);
        set(handles.seg_info,'data','');
    end  
function traj_next_Callback(hObject, eventdata, handles)
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end    
    segmentation_configs = temp{1,1};
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
    % if the trajectory has segments
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
        set(handles.seg_list,'Value',1); %select the first value
        set(handles.seg_list,'String',list_data);  
    % if the trajectory has no segments
    else
        list_data{1} = 'Trajectory';
        set(handles.seg_list,'Value',1); %select the first value
        set(handles.seg_list,'String',list_data);
        set(handles.seg_info,'data','');
    end    
function id_ok_Callback(hObject, eventdata, handles)
    temp = get(handles.select_file,'UserData');
    if isempty(temp)
        errordlg('No segmentation_configs file loaded.');
        return;
    end    
    segmentation_configs = temp{1,1};
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
    % if the trajectory has segments
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
        set(handles.seg_list,'Value',1); %select the first value
        set(handles.seg_list,'String',list_data);  
    % if the trajectory has no segments    
    else
        list_data{1} = 'Trajectory';
        set(handles.seg_list,'Value',1); %select the first value
        set(handles.seg_list,'String',list_data);
        set(handles.seg_info,'data','');
    end 