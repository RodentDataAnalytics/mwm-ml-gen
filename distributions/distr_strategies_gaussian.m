function [class_map] = distr_strategies_gaussian(segmentation_configs, classification_configs, varargin)

    HARD_BOUNDS = 0;
    SIGMA = 0;
    for i = 1:length(varargin)
        if isequal(varargin{i},'HARD_BOUNDS')
            HARD_BOUNDS = varargin{i+1};
        elseif isequal(varargin{i},'SIGMA')
            SIGMA = varargin{i+1};
        end
    end

    % Classes
    classes = unique(classification_configs.CLASSIFICATION.class_map);
    classes = classes(2:end);
    
    segments_per_class = zeros(1,length(classes));
    perc_segments_per_class = zeros(1,length(classes));
    for i = 1:length(classes)
        iseg = find(classification_configs.CLASSIFICATION.class_map == i);
        segments_per_class(1,i) = length(iseg);
        perc_segments_per_class(1,i) = 100 * segments_per_class(1,i) / length(classification_configs.CLASSIFICATION.class_map);
    end
    
    % w = 1/probability(class)
    w = 1./perc_segments_per_class;

    if HARD_BOUNDS
        avg_w = mean(w);
        for i = 1:length(w);
            if w(i) < avg_w
                w(i) = min(avg_w);
            else
                w(i) = max(avg_w);
            end
        end
    end

    % Maximum partitions
    nbins = max(segmentation_configs.PARTITION);
    % Mapping
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
    
    % For each trajectory (excluding unsegmented ones)
    for i = 1:size(class_map,1)
        % Hold the score for each strategy
        class_distr_traj = ones(nbins,length(classes))*-1;
        % Find the index of the last segment of this trajectory
        endIndex = length(find(class_map(i,:) ~= -1));
        % For each segment
        for j = 1:endIndex
            wi = j; %current segment
            wf = j; %overlapped segments
            coverage = offsets(i,j) + length_map(i,j);
            % Go here until coverage <= offset of last segment
            for k = j+1:endIndex
                if offsets(i,k) > coverage
                    wf = k-1-1;
                    break;
                end
            end
            % Go here for the rest of the segments
            %(after coverage >= offset of last semgnent) 
            if coverage > offsets(i,endIndex)
                wf = wi + (endIndex - j)-1;
            end
            m = (wi + wf) / 2; %mid-point
            % For the current segment until all the overlapped ones
            % after this compute the score of each strategy
            for k = wi:wf
                if class_map(i,j) > 0
                    col = class_map(i,j);
                    %equation 2, supplementary material page 7
                    if SIGMA <= 0
                        val = w(col)*exp(-(k-m)^2 / (2*(wf-wi+1)^2));
                    else
                        val = w(col)*exp(-(k-m)^2 / (2*SIGMA^2));
                    end
                    if class_distr_traj(k,col) == -1
                        class_distr_traj(k,col) = val;
                    else
                        class_distr_traj(k,col) = class_distr_traj(k,col) + val;
                    end
                end
            end 
        end
        % Based on the score form the new class_map
        for j = 1:endIndex
            [val,pos] = max(class_distr_traj(j,:));
            if val > 0
                class_map(i,j) = pos;
            else
                class_map(i,j) = 0;
            end
              %Good for visualization
    %                 val = max(class_distr_traj(j,:));
    %                 pos = ind2sub(size(class_distr_traj(j,:)),find(class_distr_traj(j,:)==val));
    %                 if length(pos) > 1 ||  val <= 0
    %                     class_map(i,j) = 0;
    %                 else
    %                     class_map(i,j) = pos;
    %                 end
        end

    end
end
