function results_strategies_transition_prob(segmentation_configs,classification_configs,varargin)
% Transition probabilities of strategies within trials for two groups of
% N animals. Rows and columns indicate the starting and ending strategies 
% respectively. Row values are normalised.

    segments_classification = classification_configs.CLASSIFICATION;
    count = length(segmentation_configs.TRAJECTORIES.items);
    partitions = segmentation_configs.PARTITION;
    group_1 = varargin{1,1};
    group_2 = varargin{1,2};
    % Select the two groups specified by the user
    trajectories_groups = arrayfun( @(t) t.group, segmentation_configs.TRAJECTORIES.items);
    trajectories_ = segmentation_configs.TRAJECTORIES.items(trajectories_groups == group_1 | trajectories_groups == group_2);
    trajectories_groups = arrayfun( @(t) t.group, trajectories_);
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs );
    % Strategies distribution
    strat_distr = segments_classification.mapping_ordered(segmentation_configs, -1, 'DiscardUnknown', 1, 'MinSegments', 1);

    % create 2 matrices
    nc = segments_classification.nclasses;
    trans_prob1 = zeros(nc, nc);
    trans_prob2 = zeros(nc, nc);
    
    traj_idx = 1;
    nseg = 0;
    prev_class = -1;
    while traj_idx <= count
        if nseg >= partitions(traj_idx)
            traj_idx = traj_idx + 1;
            nseg = 0;
            prev_class = -1;
            continue;
        end       
        nseg = nseg + 1;

        new_class = strat_distr(long_trajectories_map(traj_idx), nseg);
        if prev_class == -1
            prev_class = new_class;
        elseif prev_class ~= new_class
            % we have a transition
            if new_class > 0 && prev_class > 0
                if trajectories_groups(traj_idx) == 1                    
                    trans_prob1(prev_class, new_class) = trans_prob1(prev_class, new_class) + 1; 
                else
                    trans_prob2(prev_class, new_class) = trans_prob2(prev_class, new_class) + 1; 
                end
            end
            new_class = prev_class;
        end                                
    end
    % normalize matrices
    trans_prob1 = trans_prob1 ./ repmat(sum(trans_prob1, 2), 1, nc);
    trans_prob2 = trans_prob2 ./ repmat(sum(trans_prob2, 2), 1, nc);
    
    for i = 1:segments_classification.nclasses
        fprintf('\nClass %d: %s', i, segments_classification.classes{1,i}{1,2});
    end
    
    fn = fullfile(strcat(segmentation_configs.OUTPUT_DIR,'/'), 'trans_prob.mat');
    save(fn, 'trans_prob1','trans_prob2');
    figure; 
    trans_prob1
    imagesc(trans_prob1);
    figure;
    imagesc(trans_prob2);    
    trans_prob2    
end

