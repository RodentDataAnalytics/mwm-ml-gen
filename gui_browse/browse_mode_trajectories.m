function error = browse_mode_trajectories( obj,handles )
%BROWSE_MODE_TRAJECTORIES 

    error = 0;
    % parse UserData
    my_trajectories = obj;
    % find the location of the experiment properties (new_properties)
    my_path = handles.browse_data.UserData{1};
    my_path = fullfile(my_path,'settings','new_properties');
    try    
        load(my_path);
        % plot the arena
        cla
        plot_arena('',new_properties{:});   
        % plot the first trajectory
        plot_trajectory(obj.items(1,1));    
        set(handles.navigator,'String',1);
        % fill the table for the trajectory
        %set(handles.trajectory_info,'data',browse_table_trajectory(segmentation_configs,1));
        % fill the segments list
        browse_fill_segments_list('', 1, handles);
        set(handles.segment_info,'UserData',new_properties);
    catch
        error = 1;
    end    

end

