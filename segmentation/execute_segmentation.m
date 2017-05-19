function error = execute_segmentation(ppath,seg_length,seg_overlap,varargin)
%EXECUTE_SEGMENTATION segments and saves a trajectory

    error = 1;
    ppath = char_project_path(ppath);
    
    % Load necessary files from 'settings' folder
    try
        load(fullfile(ppath,'settings','new_properties.mat'));
        load(fullfile(ppath,'settings','animal_groups.mat'));
        load(fullfile(ppath,'settings','my_trajectories.mat'));
    catch
        error_messages(1);
        return
    end
    try
        load(fullfile(ppath,'settings','my_trajectories_features.mat'));
    catch
        error_messages(2);
        return;
    end

    % Extra options
    extra = '';
    for i = 1:length(varargin)
        if isequal(varargin{i},'dummy'); %if we do not want segments
            extra = 'dummy';
            seg_length = 0;
            seg_overlap = 0;
        end
    end
    
    % Execute the segmentation(s)
    for i = 1:length(seg_overlap)
        seg_properties = [seg_length,seg_overlap(i)];
        segmentation_configs = config_segments(new_properties, seg_properties, trajectory_groups, my_trajectories, my_trajectories_features, extra);
        save_segmentation(segmentation_configs, ppath)
    end   
    
    error = 0;
end

