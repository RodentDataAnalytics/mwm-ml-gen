function error_all = gui_generate_results(handles,eventdata)
%GUI_GENERATE_RESULTS parses all the info from the main_gui and generates
%results for the Strategies, Transitions and Probabilities.

    error_all = 1;
    b_pressed = eventdata.Source.String;
    project_path = char_project_path(get(handles.load_project,'UserData'));
    if isempty(project_path)
        error_messages(8);
        return
    end
    
    % Load the full trajectories
    try
        load(fullfile(project_path,'settings','my_trajectories.mat'));
        load(fullfile(project_path,'settings','my_trajectories_features.mat'));
        load(fullfile(project_path,'settings','new_properties.mat'));
    catch
        error_messages(1)
        return
    end
    
    % Select groups
    [groups,my_trajectories] = select_groups(my_trajectories);
    try
        if groups == -2
            return
        elseif groups == -1
            groups_all = arrayfun( @(t) t.group, my_trajectories.items);
            groups = unique(groups_all);
            if length(groups) ~= 1
                return
            end
        end
    catch
    end
           
    % Construct the trajectories_map and equalize the groups
    [exit, animals_trajectories_map, animals_ids] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman');
    if exit
        return
    end
    
    % If metrics is pressed
    if isequal(b_pressed,'Metrics')
        h = waitbar(0,'Generating metrics...','Name','Results');
        str = num2str(groups);
        str = regexprep(str,'[^\w'']',''); %remove gaps
        str = strcat('group',str);   
        output_dir = fullfile(project_path,'results','metrics',str);
        if ~exist(output_dir,'dir')
            mkdir(output_dir);
        end
        try
            results_latency_speed_length(new_properties,my_trajectories,my_trajectories_features,animals_trajectories_map,1,output_dir);
            error_all = 0;
            delete(h);
        catch
            delete(h);
            error_messages(22);
        end
        return
    end
    
    % Check selected segmentation 
    [error,project_path,segmentation_configs] = gui_check_segmentation(handles);
    if error
        return
    end
     
    % Get the advanced options:
    EXTRA_NAME = '';
    ret = get(handles.method_conf,'UserData'); 
    if isempty(ret)
        %[ STR_DISTR, TRANS_DISTR, SIGMA, INTERVAL, R_SIGMA, R_INTERVAL ]
        ret = [3,3,0,0,0,0];
    end
    if isequal(b_pressed,'Strategies')
        DISTRIBUTION = ret(1);
    elseif isequal(b_pressed,'Transitions') || isequal(b_pressed,'Probabilities')
        DISTRIBUTION = ret(2);
    end
    if DISTRIBUTION == 2 %no smooth, skip rest and add indication in the folder name
        EXTRA_NAME = '_nosmooth';
        SIGMA = 0;
        INTERVAL = 0;
    else
        SIGMA = ret(3)*ret(5);
        if SIGMA == 0 %default
            SIGMA = segmentation_configs.COMMON_PROPERTIES{8}{1}; %equals R
        end
        INTERVAL = ret(4)*ret(6);
        if INTERVAL == 0 %default
            INTERVAL = segmentation_configs.COMMON_PROPERTIES{8}{1}; %equals R
        end      
        if ret(3)*ret(5)~= 0 || ret(4)*ret(6)~= 0 %custom smooth
            EXTRA_NAME = strcat('_smooth_S',num2str(SIGMA),'_I',num2str(INTERVAL));
        end
    end

    % Full trajectories
    full_traj = 0;
    if segmentation_configs.SEGMENTATION_PROPERTIES(1) == 0 && segmentation_configs.SEGMENTATION_PROPERTIES(2) == 0
        if isequal(b_pressed,'Transitions') || isequal(b_pressed,'Probabilities')
            msgbox('Transitions and Probabilities not available for full trajectories','Info');
            return;
        elseif isequal(b_pressed,'Strategies')
            full_traj = 1;
        end
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
    [error,name,classifications,~] = check_classification(project_path,segmentation_configs,class);
    if error 
        return
    end
    
    FIGURES = 1;
    if length(classifications) > 1
        choice = questdlg('Would you like to generate figures for the interim steps?', ...
            'Figures', ...
            'Yes','No','No'); 
        switch choice
                case 'Yes'
                    FIGURES = 1;
                case 'No'
                    FIGURES = 0;
            otherwise
                    FIGURES = 0;
        end
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
                error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed, groups,...
                    'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'extra_segments',extra_segments, 'FIGURES', FIGURES, 'EXTRA_NAME', EXTRA_NAME);
            case 'No'
                error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed, groups,...
                    'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'FIGURES', FIGURES, 'EXTRA_NAME', EXTRA_NAME);
            otherwise
                error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed, groups,...
                    'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'FIGURES', FIGURES, 'EXTRA_NAME', EXTRA_NAME);
        end    
    else %Transitions or Probabilities
        error_all = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed, groups,...
            'DISTRIBUTION',DISTRIBUTION,'SIGMA',SIGMA,'INTERVAL',INTERVAL,'FIGURES', FIGURES, 'EXTRA_NAME', EXTRA_NAME);
    end
end

