function [class_map_detailed,d_points] = distr_strategies_smoothing(segmentation_configs, classification_configs, varargin)
%Maps the segments to the whole trajectories using discrete path intervals
%that depend on the size of the arena.
%Equation inspired from Gehring et al.: val = w * exp(-d^2 / (2*SIGMA^2))

% Let TMP = exp( -(d^2) / (SIGMA^2) ), where d is the distance from 
% the centre of the interval to the centre of the ii-th segment, then:
%  If d < THRESHOLD (skip segments that have minor intersection with the 
%  intervals), compute the TMP.

%% EXTRA PARAMETERS:

% HARD_BOUNDS: Switch. If on then the average class weight [avg(w)] is 
% computed. Class weights less than the avg(w) are set to min(w) and class
% weights equal or more than avg(w) are set to max(w).

% SIGMA: Specifies the span of the Gaussian. The further we are in the span
% the less effective is the contribution of the segment to the class
% assignement of the interval.

% interval_len: Length of the path intervals 

    % Default values
    R = segmentation_configs.COMMON_PROPERTIES{8}{1};
    HARD_BOUNDS = 0;
    WEIGHTS = 'com';
    THRESHOLD = (3/2)*R;
    SIGMA = (3/2)*R;
    interval_len = R/2;
    % These values specifies the minimum and the maximum possible weights
    min_w = 1/50; % 50%;
    max_w = 1; % 1%
    % Custom values
    for i = 1:length(varargin)
        if isequal(varargin{i},'HARD_BOUNDS')
            HARD_BOUNDS = varargin{i+1};
        elseif isequal(varargin{i},'SIGMA')
            SIGMA = varargin{i+1};
        elseif isequal(varargin{i},'THRESHOLD')
            THRESHOLD = varargin{i+1};
        elseif isequal(varargin{i},'INTERVAL')
            interval_len = varargin{i+1};
        elseif isequal(varargin{i},'WEIGHTS')
            WEIGHTS = varargin{i+1};
        end
    end

    % Classes
    classes = unique(classification_configs.CLASSIFICATION.class_map);
    classes = classes(2:end);
    
    % Weights
    if isequal(WEIGHTS,'com')    
        % Compute class weights ( w(class) = 1/probability(class) )
        segments_per_class = zeros(1,length(classes));
        perc_segments_per_class = zeros(1,length(classes));
        for i = 1:length(classes)
            iseg = find(classification_configs.CLASSIFICATION.class_map == i);
            segments_per_class(1,i) = length(iseg);
            perc_segments_per_class(1,i) = 100 * segments_per_class(1,i) / length(classification_configs.CLASSIFICATION.class_map);
        end
        w = 1./perc_segments_per_class;

        % Use minimum and maximum class weights    
        if HARD_BOUNDS
            avg_w = mean(w);
            for i = 1:length(w);
                if w(i) < avg_w
                    w(i) = min(avg_w);
                else
                    w(i) = max(avg_w);
                end
            end
        else
            % Make sure that there are not too small of too large weights
            a = find(w < min_w);
            for n = 1:length(a);
                w(a(n)) = min_w;
            end
            a = find(w > max_w);
            for n = 1:length(a);
                w(a(n)) = max_w;
            end        
            w = normalizations(w,'one');
            %w = w*10;
        end
    elseif isequal(WEIGHTS,'ones')
        w = ones(1,length(classes));
    end

    % Class mapping
    [class_map, length_map, segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
    % Offsets mapping
    offsets = -1.*ones(size(class_map,1),size(class_map,2));
    for i = 1:size(offsets,1)
        for j = 1:size(offsets,2)
            if ~isequal(segments{i,j},-1)
                offsets(i,j) = segments{i,j}.offset;
            else
                offsets(i,j) = -1;
            end
        end
    end   
    % Store detailed segmentation results for all the trajectories
    d_points = cell(size(class_map,1),1);
    d_lengths = -1*ones(size(class_map,1),1);
    d_offsets = -1*ones(size(class_map,1),1);
    d_rem_points = {};
    d_rem_distances = [];
    tmp_size = 0;
    k = 1;
    for i = 1:length(segmentation_configs.TRAJECTORIES.items)
        if segmentation_configs.PARTITION(i) <= 1
            continue;
        end
        trajectory_points = segmentation_configs.TRAJECTORIES.items(i).points;
        trajectory_length = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(i,10);
        % Perform detailed segmentation with specified segment length
        [seg_points,distances,rem_points,rem_distances] = detailed_trajectory_segmentation(trajectory_points,trajectory_length,'length',interval_len);
        if size(distances,1) > tmp_size
            tmp_size = size(distances,1);
        end
        for j = 1:size(seg_points,2)
            d_points{k,j} = seg_points{1,j};
            d_lengths(k,j) = distances(j,1);
            d_offsets(k,j) = distances(j,2);
        end
        d_rem_points = [d_rem_points;{rem_points}];
        d_rem_distances = [d_rem_distances;rem_distances];
        k = k + 1;
    end
    for i = 1:size(class_map,1)
        tmp = find(d_lengths(i,:) == 0);
        for j = 1:length(tmp)
            d_lengths(i,tmp(j)) = -1;
        end
        tmp = find(d_offsets(i,:) == 0);
        for j = 2:length(tmp)
            d_offsets(i,tmp(j)) = -1;
        end        
    end
    class_map_detailed = -1*ones(size(class_map,1),tmp_size);
    
    f1 = figure;

    % For each trajectory (excluding unsegmented ones)
    for i = 1:size(class_map_detailed,1)
        % Hold the score for each strategy
        class_distr_traj = ones(size(class_map_detailed,2),length(classes))*-1;
        % Find the index of the last interval of this trajectory
        endIndex = length(find(d_lengths(i,:) ~= -1));
        % If we have only 1 interval continue
        if endIndex == 1
            continue;
        end
        endIndex_traj = length(find(class_map(i,:) ~= -1));
        % For each interval
        for j = 1:endIndex
            if j==endIndex
                ff=50;
            end
            interval_length = d_lengths(i,j);
            interval_offset = d_offsets(i,j);
            interval_cov = interval_length + interval_offset;
            wi = 1; %first segment overlapping the interval
            wf = 1; %final segment overlapping the interval
            s = 0;
            %find the indexes of the segments overlapping the interval
            for ii = 1:endIndex_traj
                segment_cov = offsets(i,ii) + length_map(i,ii); 
                % check if segment is before the interval (skip it)
                if segment_cov < interval_cov
                    wi = ii;
                    s = 1;
                    continue;
                end
                % check if segment is after the interval (end loop)
                if offsets(i,ii) > interval_cov
                    wf = ii - 1;
                    s = 1;
                    break;
                end
            end           
            if wf < wi
                wf = wi;
            end
            if s == 0
                wf = endIndex_traj;
            end
            % For the current segment until all the overlapped ones...
            % after this compute the score of each strategy
            cla
            plot_arena(segmentation_configs);
            hold on
            for ii = wi:wf
                plot_trajectory(segmentation_configs.SEGMENTS.items(ii),'LineWidth',2);
                hold on
            end
            for p = 2:size(d_points{i,j},1)
                plot(d_points{i,j}(p-1:p,2),d_points{i,j}(p-1:p,3),'r-');
            end
            for ii = wi:wf
                if class_map(i,ii) > 0
                    col = class_map(i,ii);
                    % Compute the distance from the centre of the interval
                    % to the centre of the ii-th segment
                    m_int = interval_cov - (interval_length / 2);
                    m_seg = offsets(i,ii) + (length_map(i,ii) / 2);
                    d = m_seg - m_int;
                    % Skip segments that are far away from the
                    % interval (minor intersection)
                    if abs(d) > THRESHOLD && THRESHOLD ~= -1
                        continue;
                    end
                    % Main equation
                    tmp = exp(-(d^2) / (SIGMA^2));
                    val = w(col)*tmp; 
                    % Store score of each strategy per interval
                    if class_distr_traj(j,col) == -1
                        class_distr_traj(j,col) = val;
                    else
                        class_distr_traj(j,col) = class_distr_traj(j,col) + val;
                    end           
                end
            end            
        end  
        % Based on the score form the new class_map
        for j = 1:endIndex
            [val,pos] = max(class_distr_traj(j,:));
            if val ~= -1
                class_map_detailed(i,j) = pos;
            else
                class_map_detailed(i,j) = 0;
            end
        end
    end
end
