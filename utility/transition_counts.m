function tpm = transition_counts(segmentation_configs,classification_configs)
%TRANSITION_COUNTS counts the times in which the animals are changing their
%strategy

    % Strategies distribution
    [strat_distr, ~, ~, ~] = distr_strategies(segmentation_configs, classification_configs);
    %[strat_distr,~] = strats_distributions(segmentation_configs,classification_configs); 
    % Classification
    segments_classification = classification_configs.CLASSIFICATION;
    tpm = zeros(1, segments_classification.segments.parent.count);
    traj_idx = -1;            
    prev_class = -1;        
    seg_idx = segments_classification.segments.segmented_mapping;
    par_map = segments_classification.segments.parent_mapping;
    for i = 1:segments_classification.segments.count                                
        if par_map(i) ~= traj_idx                
            traj_idx = par_map(i);                    
            prev_class = strat_distr(seg_idx(traj_idx), segments_classification.segments.items(i).segment);                    
        end       
        class = strat_distr(seg_idx(traj_idx), segments_classification.segments.items(i).segment);
        if prev_class ~= class
            % we have a transition
            if class > 0 && prev_class > 0                                                
                tpm(traj_idx) = tpm(traj_idx) + 1;                        
            end
            prev_class = class;
        end                                
    end
end

