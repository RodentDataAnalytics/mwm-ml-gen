function [ output_args ] = interpolation(tstrat_distr, trajectory_items, trajectory_lengths, interval)
%INTERPOLATION Summary of this function goes here
%   Detailed explanation goes here

    seg_properties = segmentation_configs.SEGMENTATION_PROPERTIES;
    interval = seg_properties(1) * (1 - seg_properties(2));
    
    all_trajectories = segmentation_configs.TRAJECTORIES.items;
    long_trajectories_map = find(long_trajectories(segmentation_configs) == 0); 
    all_trajectories(long_trajectories_map) = [];
    
    %[class_map, length_map, segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
    %all_segments = segmentation_configs.SEGMENTS;
    %traj_lengths = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,10);
    %[strat_distr,~,length_maps] = strats_distributions(segmentation_configs,classification_configs);
    
    for i = 1:length(all_trajectories)
        traj_length = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(i,10);
        points = all_trajectories(i).points; %get X, Y
        parts = floor(traj_length / interval);
        re = traj_length - (interval * parts);
        points_parts = cell(1,parts);
        %endIndex = find(class_map(i,:) ~= -1); %find the last index
        for j = 1:parts
            tmp_length = 0;
            pi = 2;
            points_parts{1,j} = points(pi-1,:);
            flag = 1;
            while tmp_length < interval
                points_parts{1,j} = [ points_parts{1,j} , points(pi,:) ];
                tmp_length = tmp_length + norm(points(pi, 2:3) - points(pi-1, 2:3));
                pi = pi + 1;
            end
            tmp_rem_length = interval - tmp_length;
            extra_length = tmp_length;
            tp = [points(pi, 2:3) ; points(pi-1, 2:3)];
            k = 1;
            while flag
                x = tp(1:2,2);
                y = tp(1:2,3);
                X = x(1):x(2);
                Y = interp1(x,y,X);
                new_point = [-1,X(end),Y(end)];
                d = norm(new_point(1,2:3) - points(pi-1,2:3));
                extra_length = extra_length + d;
                if 
        end
                
        
for ii = 2:size(points,1)
    n = 10; %for example
    A(1) = points(ii-1,2);
    A(2) = points(ii-1,3);
    B(1) = points(ii,2);
    B(2) = points(ii,3);
    xy = [linspace(A(1),B(1),n); linspace(A(2),B(2),n)];
    for j = 1:size(xy,2)
        tmp = [xy(1,j),xy(2,j)];
        n_points = [n_points;tmp];
    end
end
points = [ones(size(n_points,1),1),n_points];
        traj_length = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(traj_id,10); %get trajectory length
        seg_cov = traj_length/endIndex; %split the traj into equal lengths (length)    
    
    


end

