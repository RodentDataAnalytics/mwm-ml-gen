function browse_select_segment(handles,varargin)
%BROWSE_SELECT_SEGMENT

    mode = get(handles.plotter,'UserData');
    if isempty(mode)
        return;
    end    
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'mode')
            mode = varargin{i+1};
        end
    end

    if mode == 3 || mode == 4 % we are working with the whole trajectories
        set(handles.listbox,'Value',1)
        % get current trajectory number
        idx = get(handles.navigator,'String');
        try
            if isempty(str2num(idx))
                return
            end  
        catch
            return
        end  
        idx = str2num(idx);
        % fill tags
        % refresh the tag_box
        labels = get(handles.listbox,'UserData'); 
        if isempty(labels)
            return
        end
        indexes = labels{1};
        index = find(indexes == idx);
        tags = '';
        % get the tags if exist
        if ~isempty(index)
            i = 1;
            while i<=length(labels{2}(index,:)) &&  ~isequal(labels{2}{index,i},'');
                tags{i} = labels{2}{index,i};
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        end   
        set(handles.tag_box,'String',tags); 
        return
    end
    
    % parse UserData
    segmentation_configs = get(handles.trajectory_info,'UserData');
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
        segment_data = cell(1,length(get(handles.segment_info,'Data')));
        % empty segment table
        for i = 1:length(segment_data)
            segment_data{i} = '';
        end    
        set(handles.segment_info,'data',segment_data');
        % empty tags
        set(handles.tag_box,'String','');
        % plot the arena
        plot_arena(segmentation_configs);
        % plot the trajectory
        plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,idx));    
        browse_select_segment(handles,'mode',3);
    else
        index = index-1; % because the first index = 'Trajectory'
        % fill segment table
        segment = segmentation_configs.SEGMENTS.items(1,segs(1,index));
        segment_features = segmentation_configs.FEATURES_VALUES_SEGMENTS(segs(1,index),:);
        segment_data = [segs(1,index) , segment.offset , segment_features];
        set(handles.segment_info,'data',segment_data');
        % draw the segment on the plotter
        plot_arena(segmentation_configs);
        plot_trajectory(segment,'LineWidth',1.5);  
        % fill tags
        seg_num = get(handles.segment_info, 'data');
        if isempty(seg_num(1))
            return;
        end    
        seg_num = seg_num(1);
        % refresh the tag_box
        labels = get(handles.tag_box,'UserData'); 
        if isempty(labels)
            tags = '';
            return
        end
        indexes = labels{1};
        index = find(indexes == seg_num);
        tags = '';
        % get the tags if exist
        if ~isempty(index)
            i = 1;
            while i<=length(labels{2}(index,:)) &&  ~isequal(labels{2}{index,i},'');
                tags{i} = labels{2}{index,i};
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        end   
        set(handles.tag_box,'String',tags);           
    end
end

