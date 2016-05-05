function [ returnVars ] = animals( segmentation_configs, choice, varargin )
% ANIMALS returns some statistics about the animals
    
    %% General %%
    groups = arrayfun( @(t) t.group, segmentation_configs.TRAJECTORIES.items); 
    trials = arrayfun( @(t) t.trial, segmentation_configs.TRAJECTORIES.items); 
    sessions = arrayfun( @(t) t.session, segmentation_configs.TRAJECTORIES.items); 
    id = arrayfun( @(t) t.id, segmentation_configs.TRAJECTORIES.items); 
    
    %% Count Animals per Group per Trial %%
    %          trial 1 . . .
    % group 1  count
    %   .
    %   .
    %   .
    % Example: (trial 1, group 2): in trial 1 we had 'count' animals beloging to group 2 
    animal_groups_per_trial = zeros(length(unique(groups)),length(unique(trials)));
    for k = 1:length(segmentation_configs.TRAJECTORIES.items)
        i = segmentation_configs.TRAJECTORIES.items(1,k).group;
        j = segmentation_configs.TRAJECTORIES.items(1,k).trial;
        animal_groups_per_trial(i,j) = animal_groups_per_trial(i,j)+1;
    end
    
    %% Animals IDs per Group per Trial %%
    map = {};
    ids = {};
    trial_idx = {};
    for i = 1:length(unique(groups))
        for j = 1:length(unique(trials))
            map{i,j} = find(groups == i & trials == j); % traj #
            ids{i,j} = arrayfun(@(x) x.id, segmentation_configs.TRAJECTORIES.items(map{i,j})); % actual ids
        end
    end  
    
    %% Average Speed and Mapping %%
    speed = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,11)';
    % number of groups and number of trials
    [num_g, num_t] = size(map);
    for g = 1:num_g % for each group
        % construct another map
        % assuming that each trial has the same number of animals
        map_2 = zeros(num_t,length(map{g,1}));
        for i = 1:num_t
            for j = 1:length(map{g,1})
                map_2(i,j) = map{g,i}(1,j);
            end
        end
        avg_speed{g} = mean(speed(map_2));
        % matrix of trajectory indices for each trial and group of animals
        animals_trajectories_map{g} = map_2;
    end   
    
    switch choice
        case 1 % test 
            % varargin: contains 2 numbers indicating which groups
            [animals_ids, animals_trajectories_map] = test_control_stress_speed_lat (...
                        animals_trajectories_map,segmentation_configs.COMMON_SETTINGS{1,2}{1,1},...
                        segmentation_configs.COMMON_SETTINGS{1,4}{1,1},animals_trajectories_map{1,varargin{1,1}},...
                        animals_trajectories_map{1,varargin{1,2}},ids,speed);
            returnVars = {animals_trajectories_map, animals_ids};        
       %case 2
       %.... other cases if other animal statistics are required.
    end            
end

