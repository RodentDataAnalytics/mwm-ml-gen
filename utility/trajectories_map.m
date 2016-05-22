function [groups_, animals_ids, animals_trajectories_map] = trajectories_map(segmentation_configs,varargin)    
% ANIMAL_STATISTICS constructs a matrix of trajectory indices for each 
% trial and user's defined group(s) of animals.

    groups = arrayfun( @(t) t.group, segmentation_configs.TRAJECTORIES.items);
    trials = arrayfun( @(t) t.trial, segmentation_configs.TRAJECTORIES.items);
    speed = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,11); 
    animals_ids = {};
    animals_trajectories_map = {};

    % First check if user input is correct
    groups_ = validate_groups(unique(groups),varargin{:});
    if groups_(1,1) == -1
        return;
    end

    for i = 1:length(groups_)
        % select ids based on first trial
        map = find(groups == groups_(i) & trials == 1);
        ids = arrayfun( @(x) x.id, segmentation_configs.TRAJECTORIES.items(map));
        % do the same for every trial
        for t = 2:length(unique(trials))
            trial_idx = find(groups == groups_(i) & trials == t);
            trial_ids = arrayfun( @(x) x.id, segmentation_configs.TRAJECTORIES.items(trial_idx));
            map = [map; arrayfun( @(id) trial_idx(trial_ids == id), ids)];
        end
    
        % for the published results: exclude too slow/too fast animals
        if length(varargin) > 2
            [ids, map] = published_animal_results(i,speed,ids,map);
        end    
        
        animals_ids = [animals_ids, ids];
        animals_trajectories_map = [animals_trajectories_map, map];
    end   
end