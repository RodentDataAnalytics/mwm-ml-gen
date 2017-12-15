function error = full_trajectory_features(ppath,varargin)
%FULL_TRAJECTORY_FEATURES computes the features for the whole swimming
%path of the animal
    error = 0;
    % Load necessary files from 'settings' folder
    try
        load(fullfile(ppath,'settings','new_properties.mat'));
        load(fullfile(ppath,'settings','my_trajectories.mat'));
    catch
        error = 1;
        error_messages(1);
        return;
    end
    
    % Stupid thing that I have to get rid of!
    properties = new_properties(1:18);
    for i = 1:length(properties)
        if mod(i,2) == 0
            value = properties{i};
            properties{i} = {value};
        end
    end      

    my_trajectories_features = compute_features(my_trajectories.items, features_list, properties, varargin{:});
    f = fullfile(ppath,'settings','my_trajectories_features.mat');
    save(f,'my_trajectories_features');
    
    % Create also a segmentation object
    execute_segmentation(ppath,99,1,'dummy');
end

