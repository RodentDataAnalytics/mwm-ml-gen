function [trajectories_strat_distr, trajectories_strat_distr_norm, trajectories_punknown] = classification_extra( segmentation_configs, classification_configs )
%CLASSIFICATION_EXTRA Summary of this function goes here
%   Detailed explanation goes here

    clustering_res = classification_configs.CLASSIFICATION;
    partitions = segmentation_configs.PARTITION;

    % Define the distribution of classes for the complete trajectories
    trajectories_strat_distr = clustering_res.classes_distribution(segmentation_configs, 'EmptyClass', 9);

    % Normalized version
    trajectories_strat_distr_norm = trajectories_strat_distr;
    trajectories_strat_distr_norm(partitions > 0, :) = trajectories_strat_distr(partitions > 0, :) ./ ...
                repmat(partitions(partitions > 0)', 1, size(trajectories_strat_distr, 2));

    trajectories_punknown = zeros(length(partitions));
    idx = find(partitions > 0);
    trajectories_punknown(idx) = (partitions(idx) - sum(trajectories_strat_distr(idx, :) > 0, 2)') ./ partitions(idx);
        
end

