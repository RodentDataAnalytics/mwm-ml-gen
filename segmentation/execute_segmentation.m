function error = execute_segmentation(ppath,seg_length,seg_overlap)
%EXECUTE_SEGMENTATION segments and saves a trajectory

    error = 1;
    ppath = char_project_path(ppath);
    
    % Load necessary files from 'settings' folder
    files = fullfile(ppath,'settings','*.mat');
    if isempty(files)
        errordlg('No data have been imported for this project');
    end
    try
        load(fullfile(ppath,'settings','new_properties.mat'));
        load(fullfile(ppath,'settings','animal_groups.mat'));
        load(fullfile(ppath,'settings','my_trajectories.mat'));
    catch
        errordlg('Cannot load project settings','Error');
        return
    end
    
    % Execute the segmentation(s)
    for i = 1:length(seg_overlap)
        seg_properties = [seg_length,seg_overlap(i)];
        segmentation_configs = config_segments(new_properties, seg_properties, trajectory_groups, my_trajectories);
        save_segmentation(segmentation_configs, ppath)
    end   
    
    error = 0;
end

