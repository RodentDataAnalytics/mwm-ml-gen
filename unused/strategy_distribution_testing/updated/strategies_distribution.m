function [distr_maps_segs,w,true_length_maps] = strategies_distribution(segmentation_configs,classification_configs,varargin) 

    REMOVE_DIRECT_FINDING = 1;
    
    %% INITIALIZE USER INPUT %%
    WEIGHTS_ONES = 1;   
    HARD_BOUNDS = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'WEIGHTS_ONES')
            WEIGHTS_ONES = varargin{i+1};
        elseif isequal(varargin{i},'HARD_BOUNDS')
            HARD_BOUNDS = varargin{i+1};
        end
    end     

    %% INITIALIZE VARIABLES
    [distr_maps_segs, length_map, my_segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',REMOVE_DIRECT_FINDING);
    tags = length(classification_configs.CLASSIFICATION_TAGS);
    
    % Remove the Direct Finding
    idx = find(segmentation_configs.PARTITION ~= 0);
    traj_lengths = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,10);
    traj_lengths = traj_lengths(idx);

    % Detailed classification analysis of the trajectory
    [repl_distr_maps_segs,true_length_maps] = classified_trajectory_arrangement(distr_maps_segs,length_map,my_segments,traj_lengths);
    
    % Compute class weights
    if WEIGHTS_ONES == 1
        w = ones(1,tags);
    else
    	w = class_weights(repl_distr_maps_segs,true_length_maps,tags);
    end
    
    % Extra options for the weights (no effect if weights are ones)
    if HARD_BOUNDS == 1
        w = hard_bounds(w);
    end
    
    % Voting for each sub-segment
    [distr_maps_segs] = subsegments_voting(repl_distr_maps_segs,true_length_maps,my_segments,distr_maps_segs,length_map,w);
end