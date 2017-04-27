function [ long_trajectories_map ] = long_trajectories( segmentation_configs )
%LONG_TRAJECTORIES returns the trajectories with length > 0

    long_trajectories_idx = find(segmentation_configs.PARTITION ~= 0);
    long_trajectories_map = 1:length(segmentation_configs.PARTITION);
    long_trajectories_map(segmentation_configs.PARTITION == 0) = 0;
    long_trajectories_map(segmentation_configs.PARTITION ~= 0) = 1:length(long_trajectories_idx);
    
    z = find(long_trajectories_map == 0); %we are having whole trajectories
    if length(z) == length(long_trajectories_map)
        long_trajectories_map = 1:length(z);
    end
end

