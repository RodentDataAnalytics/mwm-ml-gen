function [ error ] = browse_extra_segments(handles,segmentation_configs)
%BROWSE_EXTRA_SEGMENTS coverts trajectories without segments to segments

    set(handles.load_configuration, 'enable', 'off');
    set(handles.export, 'enable', 'off');
    set(handles.export_all, 'enable', 'off');
    set(handles.navigator, 'enable', 'off');
    set(handles.ok, 'enable', 'off');
    set(handles.counting, 'visible', 'off');
    
    browse_mode_segmentation(segmentation_configs,handles)
    full_trajectories = find(segmentation_configs.PARTITION == 0);
    idx = full_trajectories(1);
    
    % plot
    cla
    plot_arena(segmentation_configs);   
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,idx));    
    set(handles.navigator,'String',idx);
    % fill the table for the trajectory and the Labelling box
    set(handles.trajectory_info,'data',browse_table_trajectory(segmentation_configs,idx));  
    browse_fill_segments_list(segmentation_configs, idx, handles);
    % store info
    set(handles.trajectory_info,'UserData',segmentation_configs);
    set(handles.plotter,'UserData',4);
    set(handles.tag_box,'UserData',[]);
    set(handles.listbox,'UserData',[]);
    set(handles.navigator,'UserData',full_trajectories);    
end

