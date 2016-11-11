function error_all = gui_generate_results(handles,eventdata)
%GUI_GENERATE_RESULTS parses all the info from the main_gui and generates
%results for the Strategies, Transitions and Probabilities.

    error_all = 1;
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
    project_path = char_project_path(project_path);
    
    % Select groups
    groups = select_groups(segmentation_configs);
    try
        if groups == -2
            return
        end
    catch
    end
    
    % Construct the trajectories_map and equalize the groups
    if ~isequal(b_pressed,'Probabilities'); %probabilities do not use map
        [exit, animals_trajectories_map] = trajectories_map(segmentation_configs,groups,'Friedman');
        if exit
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
            error_all = 0;
        catch
            errordlg('Cannot generate metrics','Error');
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
    [error,name,classifications] = check_classification(project_path,segmentation_configs,class);
    if error 
        return
    end
    
    % Generate the results
    error_all = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups);
end

