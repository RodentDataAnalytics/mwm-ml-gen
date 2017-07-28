function [class_map_detailed,d_points,store_d,class_map_detailed_flat,time_per_segment,rem_time] = distr_strategies_smoothing(segmentation_configs, classification_configs, varargin)
%Maps the segments to the whole trajectories using discrete path intervals
%that depend on the size of the arena.
%Equation inspired from Gehring et al.: val = w * exp(-d^2 / (2*SIGMA^2))

% Smoothing equation: TMP = exp( -(d^2) / (SIGMA^2) ), where d is the 
% distance from the centre of the interval to the centre of the ii-th 
% segment.

%% EXTRA PARAMETERS:

% WEIGHTS: 'ones' ==> all class weights equal to one.
%          'com'  ==> computed class weights based on probability (default)

% HARD_BOUNDS: Switch. If on then the average class weight [avg(w)] is 
% computed. Class weights less than the avg(w) are set to min(w) and class
% weights equal or more than avg(w) are set to max(w). (default = 'off')

% SIGMA: Specifies the span of the Gaussian. The further we are in the span
% the less effective is the contribution of the segment to the class
% assignement of the interval.
% (default = radius of the arena)

% interval_len: Length of the path intervals.
% (default = radius of the arena)

% THRESHOLD: Skips segments with minor intersection with the intervals.
% If distance of segment from interval is more than the THRESHOLD, this
% segment is skipped; if d > THRESHOLD -> skip.
%(default = -1 , 'off')

% STHRESHOLD: Soft version of THRESHOLD. First compute TMP and if it is
% less than the STHRESHOLD skip the segment; if TMP < THRESHOLD.
% (default = 0.14)
    
    % DEBUG
    DEBUG = 0;
    DEBUG_SPEED = 1.5;
    
    % Arena radius
    R = segmentation_configs.COMMON_PROPERTIES{8}{1};
    
    % Default values
    WEIGHTS = 'com';
    HARD_BOUNDS = 0;
    interval_len = R;
    SIGMA = R;
    THRESHOLD = -1;
    STHRESHOLD = 0.14;
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
        elseif isequal(varargin{i},'STHRESHOLD')
            STHRESHOLD = varargin{i+1};
        elseif isequal(varargin{i},'INTERVAL')
            interval_len = varargin{i+1};
        elseif isequal(varargin{i},'WEIGHTS')
            WEIGHTS = varargin{i+1};
        end
    end

    if STHRESHOLD >= 0
        THRESHOLD = -1;
    end
    
    try
        tmp = classification_configs.CLASSIFICATION_TAGS;
        Flag = 1;
    catch %class_map is given
        Flag = 0;
    end
        
    % Classes
    %classes = unique(classification_configs.CLASSIFICATION.class_map);
    %classes = classes(2:end);
    if Flag
        classes = 1:length(classification_configs.CLASSIFICATION_TAGS);
        cmap = classification_configs.CLASSIFICATION.class_map;
    else
        tmp = unique(classification_configs);
        classes = 1:length(tmp)-1;
        cmap = classification_configs;
    end
    
    % Weights
    if isequal(WEIGHTS,'com')    
        % Compute class weights ( w(class) = 1/probability(class) )
        segments_per_class = zeros(1,length(classes));
        perc_segments_per_class = zeros(1,length(classes));
        for i = 1:length(classes)
            iseg = find(cmap == i);
            segments_per_class(1,i) = length(iseg);
            perc_segments_per_class(1,i) = 100 * segments_per_class(1,i) / length(cmap);
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
        end
    elseif isequal(WEIGHTS,'ones')
        w = ones(1,length(classes));
    else
        disp('Warning: wrong WEIGHTS option. All class weights will are set to 1');
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
        if segmentation_configs.PARTITION(i) < 1
            continue;
        elseif segmentation_configs.PARTITION(i) == 1 %trajectory turned to segment
            d_points{k,1} = segmentation_configs.SEGMENTS.items(2).points;
            d_lengths(k,1) = segmentation_configs.FEATURES_VALUES_SEGMENTS(i,10);
            d_offsets(k,1) = segmentation_configs.SEGMENTS.items(2).offset;  
            d_rem_points = [d_rem_points;{[0,0,0]}];
            d_rem_distances = [d_rem_distances;{[0,0,0]}];
            k = k + 1;
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
    
    if DEBUG
        f1 = figure;
        straj = find(segmentation_configs.PARTITION > 1);
    end

    % For each trajectory (excluding unsegmented ones)
    for i = 1:size(class_map_detailed,1)
        % Hold the score for each strategy
        class_distr_traj = ones(size(class_map_detailed,2),length(classes))*-1;
        % Find the index of the last interval of this trajectory
        endIndex = length(find(d_lengths(i,:) ~= -1));
        % If we have only 1 interval continue
        if endIndex == 1
            class_map_detailed(i,1) = class_map(i,1); %trajectory turn to segment
            continue;
        end
        endIndex_traj = length(find(class_map(i,:) ~= -1));
        % For each interval
        for j = 1:endIndex
            interval_length = d_lengths(i,j);
            interval_offset = d_offsets(i,j);
            interval_cov = interval_length + interval_offset;
            wi = 1; %first segment overlapping the interval
            wf = 1; %final segment overlapping the interval
            %find the indexes of the segments overlapping the interval
            for ii = 1:endIndex_traj
                segment_cov = offsets(i,ii) + length_map(i,ii); 
                if segment_cov == segmentation_configs.FEATURES_VALUES_TRAJECTORIES(i,10);
                    % if we have reached the last segment
                    wf = endIndex_traj;
                    break;
                else
                    % check if segment is before the interval (skip it)
                    if segment_cov < interval_cov
                        wi = ii;
                        continue;
                    end
                    % check if segment is after the interval (end loop)
                    if offsets(i,ii) > interval_cov
                        wf = ii - 1;
                        break;
                    end
                end
            end           
            if wf < wi
                wf = endIndex_traj;
            end
            % For the current segment until all the overlapped ones...
            % after this compute the score of each strategy
            if DEBUG
                cla
                plot_arena(segmentation_configs);
                hold on
                plot_trajectory(segmentation_configs.TRAJECTORIES.items(straj(i)));
                hold on
                for ii = wi:wf
                    cm = segmentation_configs.CUM_PARTITIONS;
                    if cmap(ii + cm(straj(i))) == 0
                        plot_trajectory(segmentation_configs.SEGMENTS.items(ii + cm(straj(i))),'LineWidth',2,'Color','magenta');
                    else
                        plot_trajectory(segmentation_configs.SEGMENTS.items(ii + cm(straj(i))),'LineWidth',2);
                    end
                    hold on
                end
                for p = 2:size(d_points{i,j},1)
                    plot(d_points{i,j}(p-1:p,2),d_points{i,j}(p-1:p,3),'r-','LineWidth',1.5);
                end
                str = strcat('traj:',num2str(straj(i)));
                text(-R-10,R,str);
                str = strcat('segs=wi:wf==>',num2str(wi),':',num2str(wf),'/',num2str(endIndex_traj));
                text(-R-10,R-10,str);
                str = strcat('interval==>',num2str(j),'/',num2str(endIndex));
                text(-R-10,R-20,str);
                pause(DEBUG_SPEED);
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
                    % interval (minor intersection). HARD THRESHOLD
                    if abs(d) > THRESHOLD && THRESHOLD >= 0
                        continue;
                    end
                    % Main equation
                    tmp = exp(-(d^2) / (2*(SIGMA^2)));
                    % Skip segments that are far away from the
                    % interval (minor intersection). SOFT THRESHOLD
                    if tmp < STHRESHOLD && THRESHOLD < 0
                        continue;
                    end
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
    
    %form the flat class map (vector)
    class_map_detailed_flat = [];
    for i = 1:size(class_map_detailed,1)
        idx = length(find(class_map_detailed(i,:) ~= -1));
        class_map_detailed_flat = [class_map_detailed_flat,class_map_detailed(i,1:idx)];
    end
    store_d = d_rem_points;
    %store_dist = d_rem_distances;
    % Return also the time of each segment
    [time_per_segment,rem_time] = intervals_time(d_points, store_d);
    
end
