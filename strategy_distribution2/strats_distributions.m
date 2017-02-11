function [distr_maps_segs,w] = strats_distributions(segmentation_configs,classification_configs,varargin) 

    STRATEGIES_DISTRIBUTION = 3;
    WEIGHTS_NORMALIZATION = 1;
    HARD_BOUNDS = 0;
    REMOVE_UNDEFINED = 1;

    %% INITIALIZE USER INPUT %%
    for i = 1:length(varargin)
        if isequal(varargin{i},'STRATEGIES_DISTRIBUTION')
            STRATEGIES_DISTRIBUTION = varargin{i+1};
        elseif isequal(varargin{i},'WEIGHTS_NORMALIZATION')
            WEIGHTS_NORMALIZATION = varargin{i+1};
        elseif isequal(varargin{i},'HARD_BOUNDS')
            HARD_BOUNDS = varargin{i+1};
        end
    end     

    %% INITIALIZE VARIABLES
    % all the segments
    segments = segmentation_configs.SEGMENTS.items;
    partitions = segmentation_configs.PARTITION;
    segment_length = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,10)';
    length_map = -1.*ones(length(partitions),max(partitions));
    distr_map = -1.*ones(length(partitions),max(partitions));
    idx = 1;
    for i = 1:length(partitions)
        if partitions(i) == 0 % Direct Finding
            distr_map(i,:) = -2;
        else
            for j = 1:(partitions(i))
                distr_map(i,j) = classification_configs.CLASSIFICATION.class_map(idx);
                length_map(i,j) = segment_length(idx);
                idx = idx + 1;
            end
            idx = cumsum(partitions);
            idx = idx(i)+1;
        end
    end
    % Remove DF
    rem = [];
    for i = 1:size(distr_map,1)
        if length(find(distr_map(i,:)==-2)) == max(partitions)
            rem = [rem,i];
        end
    end
    distr_maps_segs = distr_map;
    distr_maps_segs(rem,:) = [];
    length_map(rem,:) = [];
    
    % compute weights
    tags = length(classification_configs.CLASSIFICATION_TAGS);
    w = class_weights(distr_maps_segs,length_map,WEIGHTS_NORMALIZATION,HARD_BOUNDS,tags);

    %% FINAL DISTRIBUTIONS
    if STRATEGIES_DISTRIBUTION == 1 %Return original distr_maps_segs
        return;
    elseif STRATEGIES_DISTRIBUTION == 2 %Distinguish orphan strategies 
        distr_maps_segs = remove_orphan_strategies(distr_maps_segs,w);
    elseif STRATEGIES_DISTRIBUTION == 3 %Tiago
        distr_maps_segs = original_strats_distr(distr_maps_segs,segments,w,length_map);
    end
    
    %% EXTRA
    if REMOVE_UNDEFINED    
        distr_maps_segs = remove_unclassified(segmentation_configs,length_map,distr_maps_segs,w);
    end
end