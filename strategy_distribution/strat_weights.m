function [weights, lengths, strategy_used, class_map_] = strat_weights(segmentation_configs,classification_configs,varargin)
%STRAT_WEIGHTS UNDER DEVELOPMENT - OTHER METHOD FOR COMPUTING THE WEIGHTS

%varargin: normalization method for distr_undefined (code line 34). If it
%          is set to 'skip' then distr_undefined is skipped.
%class_map_: the updated class_map without unlabelled segments.
%
    
    all_segments = segmentation_configs.SEGMENTS.items;
    partitions = segmentation_configs.PARTITION;
    class_map = classification_configs.CLASSIFICATION.class_map;
    class_map_ = [];
    all_segments_length = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,10);
    index = 1;
    
    trajectory_distribution = {};
    for i = 1:length(partitions)
        if partitions(i) == 0
            continue;
        end   
        % get the segments of this trajectory
        segments = all_segments(index:index+partitions(i)-1);
        % get lengths of the segments of this trajectory
        segments_length = all_segments_length(index:index+partitions(i)-1);
        % get the unique strategies of this trajectory
        strats = unique(class_map(index:index+partitions(i)-1));
        % get class of each segments of this trajectory
        seg_classes = class_map(index:index+partitions(i)-1);
        index = index + partitions(i);
        
        %% Find the maximum length of each class in this partition %%
        strategy_length = zeros(1,length(strats));
        for l = 1:length(strats)
            strategy = find(seg_classes == strats(l));
            strategy_length(l) = segments_length(strategy(1));
            %offset(1) = 0
            trajectory_covering = segments_length(strategy(1));
            %find if segment overlaps the previous one
            for s = 2:length(strategy)
                %if it overlaps, which means if...
                %offset of this segment <= offset + length of the previous
                if segments(strategy(s)).offset <= trajectory_covering
                    %offset + length of the next segment
                    new_trajectory_covering = segments(strategy(s)).offset + segments_length(strategy(s));
                    %find the difference
                    difference = new_trajectory_covering - trajectory_covering;
                    %add the difference to the previous length                    
                    strategy_length(l) = strategy_length(l) + difference;
                %if it doesn't overlap
                else
                    strategy_length(l) = strategy_length(l) + segments_length(strategy(s));
                end    
                trajectory_covering = segments_length(strategy(s))+segments(strategy(s)).offset;
            end
        end
        
        %% Add label to undefined segments based on neighboured defined ones %%
        flag = 1;
        for v = 1:length(varargin)
            if ~isnumeric(varargin{v})
                [seg_classes, ~] = distr_undefined(strats,strategy_length,seg_classes,varargin{v});
                flag = 0;
            end    
        end
        if flag
            [seg_classes, ~] = distr_undefined(strats,strategy_length,seg_classes,'one');
        end    

        %% Find lengths of continuous classes %%
        continuous_length = segments_length(1);
        %offset + length of the first segment
        trajectory_covering = segments_length(1) + segments(1).offset;
        weights = [];
        lengths = [];
        strategy_used = [];
        for j = 2:length(seg_classes)
            if seg_classes(j-1) == seg_classes(j)
                %offset + length of the next segment
                new_trajectory_covering = segments_length(j)+segments(j).offset;
                %find the difference
                difference = new_trajectory_covering - trajectory_covering;
                %add the difference to the previous length
                continuous_length = continuous_length + difference;
                trajectory_covering = new_trajectory_covering;
                %for the last one
                if j == length(seg_classes)
                    weight_k = strategy_length(strats == seg_classes(j-1))/continuous_length;
                    weights = [weights, weight_k];
                    lengths = [continuous_length, lengths];
                    strategy_used = [strategy_used,seg_classes(j-1)];
                end    
            else
                % w = (length of continuous segs of strategy c) / 
                %     (total length of strategy c)
                weight_k = strategy_length(strats == seg_classes(j-1))/continuous_length;
                weights = [weights, weight_k];
                lengths = [continuous_length, lengths];
                strategy_used = [strategy_used,seg_classes(j-1)]; 
                %reset the continuous_length and the covering
                continuous_length = segments_length(j);
                trajectory_covering = segments_length(j) + segments(j).offset;
            end   
        end
        %trajectory_distribution = [trajectory_distribution;{weights,lengths,strategy_used}]; 
        class_map_ = [class_map_,seg_classes];
    end
    %save(strcat(segmentation_configs.OUTPUT_DIR, '/', 'trajectory_distribution', '.mat'), 'trajectory_distribution');
end