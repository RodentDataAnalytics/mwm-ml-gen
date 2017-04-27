function browse_fill_segments_list(segmentation_configs, idx, handles)
%BROWSE_FILL_SEGMENTATION_LIST 

    % get the segments of the trajectory
    if ~isempty(segmentation_configs)
        segs = find_segs_of_traj(segmentation_configs.SEGMENTS, idx);
    else
        segs = '';
    end
    % if the trajectory has segments
    if ~isempty(segs)
        list_data = cell(1,length(segs)+1);
        list_data{1} = 'Trajectory';
        for i=1:length(segs)
            list_data{i+1} = strcat('seg_',num2str(i)); 
        end
    else
        list_data{1} = 'Trajectory';
    end    
    set(handles.listbox,'Value',1); %select the first value
    set(handles.listbox,'String',list_data);  
    if length(list_data) == 1
        set(handles.segment_info,'data','');
    end  
end

