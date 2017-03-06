function [distr_maps_segs,w,true_length_maps] = strats_distributions(segmentation_configs,classification_configs,varargin) 

    PRESET = 0;
    REMOVE_DIRECT_FINDING = 1;
    REMOVE_UNDEFINED = 0;
    HARD_BOUNDS = 0;
    EQUATION_LEGACY = 0;
    WEIGHTS_NORMALIZATION = 0;
    WEIGHTS_ONES = 0;

    %% INITIALIZE USER INPUT %%
    for i = 1:length(varargin)
        if isequal(varargin{i},'PRESET')
            PRESET = varargin{i+1};
        elseif isequal(varargin{i},'REMOVE_DIRECT_FINDING')
            REMOVE_DIRECT_FINDING = varargin{i+1};
        elseif isequal(varargin{i},'HARD_BOUNDS')
            HARD_BOUNDS = varargin{i+1};
        end
    end     

    %% INITIALIZE VARIABLES
    [distr_maps_segs, length_map, my_segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',REMOVE_DIRECT_FINDING);
    tags = length(classification_configs.CLASSIFICATION_TAGS);
    w = ones(1,tags);
    
    idx = find(segmentation_configs.PARTITION ~= 0);
    traj_lengths = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,10);
    traj_lengths = traj_lengths(idx);
    
    true_length_maps = traj_lengths;

    if PRESET == 1 %Return original distr_maps_segs
        w = zeros(1,tags);
        return
    elseif PRESET == 2 %Tiago
        w = weights_legacy(classification_configs,distr_maps_segs);
        if HARD_BOUNDS == 1
            w = hard_bounds(w);
        end
        distr_maps_segs = original_strats_distr(distr_maps_segs,segmentation_configs,w,length_map);
        return
    elseif PRESET == 3 %Distinguish orphan strategies 
        w = weights_legacy(classification_configs,distr_maps_segs);    
        if HARD_BOUNDS == 1
            w = hard_bounds(w);
        end
        distr_maps_segs = remove_orphan_strategies(distr_maps_segs,w);
        return
    elseif PRESET == 4 %Tiago without undefined
        if REMOVE_UNDEFINED == 1
            distr_maps_segs = remove_unclassified(segmentation_configs,distr_maps_segs,length_map);
        end          
        if HARD_BOUNDS == 1
            w = weights_legacy(classification_configs,distr_maps_segs);
            w = hard_bounds(w);
        end        
        distr_maps_segs = original_strats_distr(distr_maps_segs,segmentation_configs,w,length_map);        
        return
    end
        
    % Remove undefined (or place the value -3)  
    if REMOVE_UNDEFINED == 1
        distr_maps_segs = remove_unclassified(segmentation_configs,distr_maps_segs,length_map);
        for i = 1:size(distr_maps_segs,1)
            for j = 1:size(distr_maps_segs,2)
                if distr_maps_segs(i,j) == -3
                    try
                        distr_maps_segs(i,j) = distr_maps_segs(i,j-1);
                    catch
                        distr_maps_segs(i,j) = distr_maps_segs(i,j+1);
                    end
                end
            end
        end        
    end    
    
    %% New methodology

    % Detailed classification analysis of the trajectory
    [repl_distr_maps_segs,true_length_maps] = classified_trajectory_arrangement(distr_maps_segs,length_map,my_segments,traj_lengths);
    
    % Compute class weights
    if WEIGHTS_ONES == 1
        w = ones(1,length(w));
    else
    	w = class_weights(repl_distr_maps_segs,true_length_maps,tags);
    end
    
    % Extra options for the weights
    if WEIGHTS_ONES == 0
        if WEIGHTS_NORMALIZATION == 1
            w = normalizations(w,'n-norm',WEIGHTS_NORMALIZATION);
        end    
        if HARD_BOUNDS == 1
            w = hard_bounds(w);
        end
    end    
    
    % Voting for each sub-segment
    if EQUATION_LEGACY == 1
        distr_maps_segs = original_strats_distr(distr_maps_segs,segmentation_configs,w,length_map);
    else
        [distr_maps_segs] = subsegments_voting(repl_distr_maps_segs,true_length_maps,my_segments,distr_maps_segs,length_map,w);
    end

    % Finally smooth the data by removing orphan strategies
    [ distr_maps_segs ] = remove_orphan_strategies(distr_maps_segs,true_length_maps,weights);
end