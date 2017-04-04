function [class_map, class_map_bk] = distr_strategies_fixed_inverval(segmentation_configs, classification_configs)
%DISTR_STRATEGIES_FIXED_INTERVAL computes the prefered strategy for a small time 
%window for each trajectory.
    
    %% INITIALIZE %%
    sigma = 4;
    % Classes
    classes = unique(classification_configs.CLASSIFICATION.class_map);
    classes = classes(2:end);
    class_w = ones(1,length(classes));
    % Maximum partitions
    nbins = max(segmentation_configs.PARTITION);
    % nbins X classes table for storing each strategy score per segment
    class_distr_traj = ones(nbins,length(classes))*-1;  
    % Mapping
    [class_map, length_map, segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
    class_map_bk = class_map; %backup
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

    %interval = segmentation_configs.EXPERIMENT_PROPERTIES{8}/2;
    interval = 75;
    % For testing: collect all the parts and the remaining
    test_parts = [];
    test_remaining = [];
    %% COMPUTE %%
    for i = 1:size(class_map,1)
        % Get the last index of the trajectory
        endIndex = length(find(class_map(i,:) ~= -1));
        % Split the trajectory using R/2 lengths
        traj_length = offsets(i,endIndex) + length_map(i,endIndex);
        cov = 0;
        parts = 0;
        parts_offset = 0;
        while cov + interval <= traj_length
            cov = cov + interval;
            parts = parts + 1;
            parts_offset = [parts_offset ; cov];
        end
        % Iterate through the parts and use Tiago's methodology (updated)
        part_s = 0;
        part_e = 0;
        p_cov = 0;
        for j = 1:parts
            % Find which segments ovelap this interval
            part_s = j*interval - interval;
            part_e = j*interval;
            p_cov = p_cov + j*interval;
            segs = [];
            part_off = j*interval - interval;
            for s = 1:endIndex
                if part_off >= (offsets(i,s) + length_map(i,s))
                    continue;
                elseif (part_off + interval) <= offsets(i,s)
                    continue;
                else
                    segs = [segs,s];  
                end
            end
            % Apply Tiago's equation
            m = sum(segs) / 2;
            for p = 1:length(segs)
                if class_map(i,segs(p)) > 0
                    col = class_map(i,segs(p));
                    val = class_w(col) * exp(-(segs(p)-m)^2/(2*sigma^2));
                    if class_distr_traj(segs(p),col) == -1
                        class_distr_traj(segs(p),col) = val;
                    else
                        class_distr_traj(segs(p),col) = class_distr_traj(segs(p),col) + val;
                    end
                end
            end
        end
        for j = 1:endIndex
            %[val,pos] = max(class_distr_traj(j,:));
            % if we have multiple maximums or val is less than zero -> UD
            val = max(class_distr_traj(j,:));
            pos = ind2sub(size(class_distr_traj(j,:)),find(class_distr_traj(j,:)==val));
            if length(pos) > 1 ||  val <= 0
                class_map(i,j) = 0;
            else
                class_map(i,j) = pos;
            end
        end
        class_distr_traj = ones(nbins,length(classes))*-1;
    end
end            
            
            
            
        
