function [distr_maps_segs, length_map, segments] = form_class_distr(segmentation_configs,classification_configs,varargin)
%FORM_CLASS_DISTR returns a matrix holding the class distributions (each
%row equals to one full trajectory).

    REMOVE_DIRECT_FINDING = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'REMOVE_DIRECT_FINDING')
            REMOVE_DIRECT_FINDING = varargin{i+1};
        end
    end     
    
    partitions = segmentation_configs.PARTITION;
    z = find(partitions == 0); %we are having whole trajectories
    if length(z) == length(partitions)
        partitions = ones(1,length(z));
    end
    
    segment_length = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,10)';
    length_map = -1.*ones(length(partitions),max(partitions));
    distr_map = -1.*ones(length(partitions),max(partitions));
    segments = num2cell(-1.*ones(length(partitions),max(partitions)));
    
    idx = 1;
    for i = 1:length(partitions)
        if partitions(i) == 0 % Direct Finding
            distr_map(i,:) = -2;
        else
            for j = 1:(partitions(i))
                try
                    distr_map(i,j) = classification_configs.CLASSIFICATION.class_map(idx);
                catch %in case the class map is given directly
                    distr_map(i,j) = classification_configs(idx);
                end
                length_map(i,j) = segment_length(idx);
                segments{i,j} = segmentation_configs.SEGMENTS.items(idx);
                idx = idx + 1;
            end
            idx = cumsum(partitions);
            idx = idx(i)+1;
        end
    end
    distr_maps_segs = distr_map;
    
    % Remove DF
    if REMOVE_DIRECT_FINDING
        rem = [];
        for i = 1:size(distr_map,1)
            if length(find(distr_map(i,:)==-2)) == max(partitions)
                rem = [rem,i];
            end
        end
        distr_maps_segs(rem,:) = [];
        length_map(rem,:) = [];
        segments(rem,:) = [];
    end
end

