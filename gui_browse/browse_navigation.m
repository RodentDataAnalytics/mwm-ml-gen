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
    end    
end

