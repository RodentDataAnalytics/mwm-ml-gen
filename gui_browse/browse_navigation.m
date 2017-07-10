function [ error ] = browse_navigation(handles,navigate)
%BROWSE_NAVIGATION

    error = 1;
    % Check what kind of object is loaded
    mode = get(handles.plotter,'UserData');
    if isempty(mode)
        return;
    end    
    
    %% SEGMENTATION OBJECT LOADED
    if mode == 1
        segmentation_configs = get(handles.trajectory_info,'UserData');
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
        % check the limits
        if navigate == 1 %specified trajectory
            if idx > length(segmentation_configs.TRAJECTORIES.items) || idx <= 0
                return
            end
        elseif navigate == 2 %next trajectory
            if idx >= length(segmentation_configs.TRAJECTORIES.items) || idx <= 0
                return
            end
            idx = idx+1;
        elseif navigate == 3 %previous trajectory  
            if idx == 1 ||  idx <= 0 || idx > length(segmentation_configs.TRAJECTORIES.items)
                return
            end
            idx = idx-1;
        else
            return            
        end
        % update pointer
        set(handles.navigator,'String',num2str(idx));
        % plot the arena
        plot_arena(segmentation_configs);
        % plot the next trajectory
        plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,idx));
        % fill the table for the trajectory
        set(handles.trajectory_info,'data',browse_table_trajectory(segmentation_configs,idx)); 
        % fill the segments list 
        browse_fill_segments_list(segmentation_configs, idx, handles);
        error = 0;
        
    %% CLASSIFICATION OBJECT LOADED    
    elseif mode == 2
        %... 
        
    elseif mode == 3    
    %% MY_TRAJECTORIES OBJECT LOADED  
        try
            my_trajectories = get(handles.trajectory_info,'UserData');
            new_properties = get(handles.segment_info,'UserData');
        catch %fix_trajectories
            my_trajectories = get(handles.b_load,'UserData');
            new_properties = get(handles.ok,'UserData');            
        end
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
        % check the limits
        if navigate == 1 %specified trajectory
            if idx > length(my_trajectories.items) || idx <= 0
                return
            end
        elseif navigate == 2 %next trajectory
            if idx >= length(my_trajectories.items) || idx <= 0
                return
            end
            idx = idx+1;
        elseif navigate == 3 %previous trajectory  
            if idx == 1 ||  idx <= 0 || idx > length(my_trajectories.items)
                return
            end
            idx = idx-1;
        else
            return            
        end
        % update pointer
        set(handles.navigator,'String',num2str(idx));
        % plot the arena
        plot_arena('',new_properties{:});
        % plot the next trajectory
        plot_trajectory(my_trajectories.items(1,idx));
        % fill the table for the trajectory
        %set(handles.trajectory_info,'data',browse_table_trajectory(segmentation_configs,idx)); 
        % fill the segments list 
        try
            browse_fill_segments_list('', idx, handles);
            % fill the tags list
            browse_select_segment(handles)
        catch%fix_trajectories
            coords = fill_coordinates_table(my_trajectories, idx);
            set(handles.coord_table,'data',coords);
        end
        error = 0;
    
    %% CONVERT TRAJECTORIES TO SEGMENTS
    elseif mode == 4
        segmentation_configs = get(handles.trajectory_info,'UserData');
        idxs = get(handles.navigator,'UserData'); 
        idx = get(handles.navigator,'String');
        try
            if isempty(str2num(idx))
                return
            end  
        catch
            return
        end  
        idx = str2num(idx);
        % check the limits
        if navigate == 2 %next trajectory
            if idx == idxs(end)
                return
            end
            idx = find(idxs == idx);
            idx = idx+1;
        elseif navigate == 3 %previous trajectory  
            if idx == idxs(1)
                return
            end
            idx = find(idxs == idx);
            idx = idx-1;
        else
            return            
        end
        % update pointer
        set(handles.navigator,'String',num2str(idxs(idx)));
        % plot the arena
        plot_arena(segmentation_configs);
        % plot the next trajectory
        plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,idxs(idx)));
        % fill the table for the trajectory
        set(handles.trajectory_info,'data',browse_table_trajectory(segmentation_configs,idxs(idx))); 
        % fill the segments list 
        browse_fill_segments_list('', idxs(idx), handles);
        error = 0;        
    end    
end

