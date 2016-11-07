function error = gui_generate_results(handles,eventdata)
%GUI_GENERATE_RESULTS parses all the info from the main_gui and generates
%results for the Strategies, Transitions and Probabilities.

    error = 1;
    b_pressed = eventdata.Source.String;
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    
    % Check selected segmentation 
    [error,project_path,segmentation_configs] = gui_check_segmentation(handles);
    if error
        return
    end
    
    % Select groups
    groups = select_groups(segmentation_configs);
    if groups == -2
        return
    end
    
    % Construct the trajectories_map and equalize the groups
    if ~isequal(b_pressed,'Probabilities'); %probabilities do not use map
        [exit, animals_trajectories_map] = trajectories_map(segmentation_configs,groups,'Friedman');
        if exit
            error = 0;
            return
        end
    else
        animals_trajectories_map = [];
    end
    
    % If metrics is pressed
    if isequal(b_pressed,'Metrics')
        output_dir = fullfile(project_path,'results');
        try
            results_latency_speed_length(segmentation_configs,animals_trajectories_map,1,output_dir);
            error = 0;
        catch
        end
        return
    end
    
    % Check selected classification
    class = get(handles.default_class,'String');
    idx = get(handles.default_class,'Value');
    class = class{idx};
    if isempty(class)
        return
    end
    [error,name,classifications] = check_classification(char(project_path),segmentation_configs,class);
    if error 
        return
    end
    
    % Generate the results
    generate_results(char(project_path), name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups);
    error = 0;
end

