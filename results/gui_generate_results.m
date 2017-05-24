function error_all = gui_generate_results(handles,eventdata)
%GUI_GENERATE_RESULTS parses all the info from the main_gui and generates
%results for the Strategies, Transitions and Probabilities.

    error_all = 1;
    b_pressed = eventdata.Source.String;
    project_path = char_project_path(get(handles.load_project,'UserData'));
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    
    % Check selected segmentation 
    [error,project_path,segmentation_configs] = gui_check_segmentation(handles);
    if error
        return
    end
     
    % Get the advanced options:
    ret = get(handles.method_conf,'UserData'); 
    if isempty(ret)
        %[ STR_DISTR, TRANS_DISTR, SIGMA, INTERVAL, R_SIGMA, R_INTERVAL ]
        ret = [3,3,0,0,0,0];
    end
    if isequal(b_pressed,'Strategies')
        DISTRIBUTION = ret(1);
    elseif isequal(b_pressed,'Transitions')
        DISTRIBUTION = ret(2);
    end
    if ret(3) == 0 %no smooth, equal to R (radius)
        SIGMA = segmentation_configs.COMMON_PROPERTIES{8}{1};
        INTERVAL = segmentation_configs.COMMON_PROPERTIES{8}{1};
    else %custom smooth
        R = ret(5);
        if R == 0
            R = 1;
        else
            R = segmentation_configs.COMMON_PROPERTIES{8}{1};
        end    
        SIGMA = ret(3)*R;
        R = ret(6);
        if R == 0;
            R = 1;
        else
            R = segmentation_configs.COMMON_PROPERTIES{8}{1};
        end         
        INTERVAL = ret(4)*R;
    end
          
    % Full trajectories
    full_traj = 0;
    if length(segmentation_configs.FEATURES_VALUES_TRAJECTORIES) == length(segmentation_configs.FEATURES_VALUES_SEGMENTS)
        if isequal(b_pressed,'Transitions') || isequal(b_pressed,'Probabilities')
            msgbox('Transitions and Probabilities not avilable for full trajectories','Info');
            return;
        elseif isequal(b_pressed,'Strategies')
            choice = questdlg('Use manual labels or classification results?','Strategies', ...
                'Manual Labels','Class Results','Manual Labels');
            switch choice
                case 'Manual Labels'
                    full_traj = 1;
                case 'Class Results'
                    full_traj = 0;
                otherwise 
                    return;
            end            
        end
    end
        
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
        str = num2str(groups);
        str = regexprep(str,'[^\w'']',''); %remove gaps
        str = strcat('group',str);   
        output_dir = fullfile(project_path,'results','metrics',str);
        if ~exist(output_dir,'dir')
            mkdir(output_dir);
        end
        try
            results_latency_speed_length(segmentation_configs,animals_trajectories_map,1,output_dir);
            error_all = 0;
        catch
            errordlg('Cannot generate metrics','Error');
        end
        return
    end
    
    % Full trajectories strategies with manual labelling 
    if full_traj == 1
        sfile = get(handles.default_segmentation,'String');
        idx = get(handles.default_segmentation,'Value');
        sfile = sfile{idx};
        lfile = get(handles.default_labels,'String');
        idx = get(handles.default_labels,'Value');
        lfile = lfile{idx};
        error_all = results_strategies_distributions_manual_full(project_path,sfile,lfile,animals_trajectories_map,1);
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
    
    if isequal(b_pressed,'Strategies')
        % Convert some of the remaining full trajectories to segments?
        choice = questdlg('Would you like to convert any remaining full trajectories to segments?', ...
            'Segmentation', ...
            'Yes','No','No');
        switch choice
            case 'Yes'
                if ~iscell(project_path)
                    tmp_path = {project_path};
                end    
                [~,extra_segments] = browse(tmp_path,segmentation_configs);
                error_all = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups,...
                    'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'extra_segments',extra_segments);
            case 'No'
                error_all = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups,...
                    'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL);
            otherwise
                error_all = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups,...
                    'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL);
        end    
    else %Transitions...
        error_all = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups,...
            'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL);
    end
end

