function error = browse_mode_segmentation(obj,handles)
%BROWSE_MODE_SEGMENTATION

    error = 0;
    % parse UserData
    segmentation_configs = obj;
    try    
        % plot the arena
        cla
        plot_arena(segmentation_configs);   
        % plot the first trajectory
        plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,1));    
        set(handles.navigator,'String',1);
        % fill the table for the trajectory
        set(handles.trajectory_info,'data',browse_table_trajectory(segmentation_configs,1));
        % fill the segments list
        browse_fill_segments_list(segmentation_configs, 1, handles);
    catch
        error = 1;
    end
end

