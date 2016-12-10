function matched = match_segments(objects,varargin)
%MATCH_SEGMENTS checks which segments of two segmentations match. Requires
%segmentations with same segments length

% INPUT:
%objects: 1x2 cell array containing segmantation configs objects.
%varargin: optional, specifies a tolerance for matching segments.

% RETURNS:
%Nx2 matrix of matched semgnent indexes

    matched = [];
    if length(objects) < 2
        disp('Nothing to match');
        return;
    elseif length(objects) > 2
        disp('Cannot match more than two objects');
        return;        
    end
    if objects{1}.SEGMENTATION_PROPERTIES(1) ~= objects{2}.SEGMENTATION_PROPERTIES(1)
        disp('Cannot match objects. Objects do not have the same segments length');
        return;           
    end
    
    % config tolerance level
    if isempty(varargin)
        tolerance = 10;
    else
        tolerance = varargin{1};
        if isempty(tolerance)
            tolerance = 10;
        end    
    end    

    % sort by number of segments (descending order)
    flag = 0; % check if order is changed
    segs_1 = objects{1}.SEGMENTS.items;
    segs_2 = objects{2}.SEGMENTS.items;
    if length(segs_1) < length(segs_2)
        flag = 1;
        temp = objects{1};
        objects{1} = objects{2};
        objects{2} = temp;
    end
    
    segs_1 = objects{1}.SEGMENTS.items;
    segs_2 = objects{2}.SEGMENTS.items;
    partition_1 = objects{1}.PARTITION;
    partition_2 = objects{2}.PARTITION;
    index_1 = 1;
    index_2 = 1;
    % for each trajectory
    for i = 1:length(partition_1)
        % if trajectory has no segments continue
        if partition_1(i) == 0 || partition_2(i) == 0
            continue;
        end  
        % take the segments of this trajectory
        segments_1 = segs_1(index_1 : partition_1(i) + index_1 -1);
        segments_2 = segs_2(index_2 : partition_2(i) + index_2 -1);  
        % for each segment of segmentation 2 see if we have a match
        for z = 1:length(segments_2)
            for k = 1:length(segments_1)
                if abs(segments_1(k).offset - segments_2(z).offset) < tolerance
                    matched = [matched ; k+index_1-1,z+index_2-1];
                    break;
                end
            end
        end 
        index_1 = index_1 + partition_1(i);
        index_2 = index_2 + partition_2(i);        
    end        
       
    % generate output
    if flag
        new_match = [matched(:,2),matched(:,1)];
        matched = new_match;
    end
end

