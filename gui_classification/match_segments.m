function [output,segmentations] = match_segments(objects,varargin)
%MATCH_SEGMENTS checks which segments of two segmentations match.

% INPUT:
%objects: 1xN cell array containing segmantation configs objects.
%varargin: optional, specifies a tolerance for matching segments.

% RETURNS:
%output (a) or (b):
% (a) length(objects)>2 generates a 1xlength(objects)-1 cell array in which
%each cell contains an Nx2 array of matched segments (first column always
%refers to the first segmentation, which is the segmentation with the most
%segments). 
% (b) length(objects)=2 generates a Nx2 array of matched segments, the first 
%column refers to the first segmentation, which is the segmentation with
%the most segments).
%segmentations:
% Segmentation objects sorted by number of segments.

    output = [];
    segmentations = [];
    % if (objects) < 2 return
    if isempty(varargin)
        tolerance = 10;
    else
        tolerance = varargin{1};
        if isempty(tolerance)
            tolerance = 10;
        end    
    end    

    % all match
    if length(objects) < 2
        if objects{1}.SEGMENTATION_PROPERTIES(2) == objects{1}.SEGMENTATION_PROPERTIES(2)
            output = 1 : size(objects{1}.FEATURES_VALUES_SEGMENTS,1);
            output = [output; 1 : size(objects{1}.FEATURES_VALUES_SEGMENTS,1)];
            output = output';
            return
        else
            return
        end
    end    
    
    % check (if objects have the same segment length
    overlaps = objects{1}.SEGMENTATION_PROPERTIES(2);
    for i = 2:length(objects)
        if objects{1}.SEGMENTATION_PROPERTIES(1) ~= objects{i}.SEGMENTATION_PROPERTIES(1)
            return;
        else
            %get the overlap
            overlaps = [overlaps, objects{i}.SEGMENTATION_PROPERTIES(2)];
        end    
    end
    % sort objects based on the overlap
    [~,idx] = sort(overlaps,'descend');
    segmentations = cell(1,length(objects));
    for i = 1:length(objects)
        segmentations{i} = objects{idx(i)};
    end    

    % first is the segmentation with the most segments
    segments_1 = segmentations{1}.SEGMENTS.items;
    partition_1 = segmentations{1}.PARTITION;
    f_matched = {};
    for i = 2:length(segmentations)
        segments_2 = segmentations{i}.SEGMENTS.items;
        partition_2 = segmentations{i}.PARTITION;
        index_1 = 1;
        index_2 = 1;
        matched = [];
        % for each trajectory
        for j = 1:length(partition_1)
            if partition_1(j) == 0
                continue;
            end    
            % take the segments of this trajectory
            segs_1 = segments_1(index_1 : partition_1(j) + index_1 -1);
            segs_2 = segments_2(index_2 : partition_2(j) + index_2 -1);
            % for each segment of segmentation 2 see if we have a match
            for z = 1:length(segs_2)
                for k = 1:length(segs_1)
                    if abs(segs_1(k).offset - segs_2(z).offset) < tolerance
                        matched = [matched ; k+index_1-1,z+index_2-1];
                        break;
                    end
                end
            end 
            index_1 = index_1 + partition_1(j);
            index_2 = index_2 + partition_2(j);
        end           
        f_matched{i} = matched;         
    end
    
    % generate output
    if length(objects) > 2
        output = f_matched;
    else
        output = matched;
    end    
end

