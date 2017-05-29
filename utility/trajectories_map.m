function [exit,animals_trajectories_map] = trajectories_map(my_trajectories,my_trajectories_features,user_groups,test,varargin)    
% ANIMAL_STATISTICS constructs a matrix of trajectory indices for each 
% trial and user's defined group(s) of animals.

    exit = 0;
    
    groups = arrayfun( @(t) t.group, my_trajectories.items);
    trials = arrayfun( @(t) t.trial, my_trajectories.items);
    speed = my_trajectories_features(:,11); 
    animals_ids = {};
    animals_trajectories_map = {};

    for i = 1:length(user_groups)
        % select ids based on first trial
        map = find(groups == user_groups(i) & trials == 1);
        ids = arrayfun( @(x) x.id, my_trajectories.items(map));
        % do the same for every trial
        for t = 2:length(unique(trials))
            trial_idx = find(groups == user_groups(i) & trials == t);
            trial_ids = arrayfun( @(x) x.id, my_trajectories.items(trial_idx));
            map = [map; arrayfun( @(id) trial_idx(trial_ids == id), ids)];
        end
    
        % for the published results: exclude too slow/too fast animals
        if ~isempty(varargin)
            if varargin{1} == 1 
                [ids, map] = published_animal_results(i,speed,ids,map);
            elseif varargin{1} == 2
            end
        end    
        
        animals_ids = [animals_ids, ids];
        animals_trajectories_map = [animals_trajectories_map, map];
    end   
    
    % Friedman's Test required equal ammount of animals but if we have only
    % one group the Friedman's Test is skipped
    if length(animals_trajectories_map) == 1
        return
    end
    
    switch test
        case 'Friedman' % we need to have equal number of animals
            if size(animals_trajectories_map,2) > 1
                if size(animals_trajectories_map{1,1},2)~=size(animals_trajectories_map{1,2},2)
                    features = my_trajectories_features(:,9:11);
                    [~, animals_trajectories_map] = equalize_groups(user_groups, animals_ids, animals_trajectories_map, features);
                    % if Cancel or X was clicked, return
                    if size(animals_trajectories_map{1,1},2)~=size(animals_trajectories_map{1,2},2)
                        exit = 1;
                        return
                    end   
                end
            end
    end
end