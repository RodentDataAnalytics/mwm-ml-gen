function [name] = generate_name_segments(segmentation_configs)
%GENERATE_NAME_SEGMENTS returns the number of segments, the segment length
%and the segment overlap as a string separated by '_'

    p1 = num2str(size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1));
    p2 = num2str(segmentation_configs.SEGMENTATION_PROPERTIES(1));
    p3 = num2str(segmentation_configs.SEGMENTATION_PROPERTIES(2));
    p3(regexp(p3,'[.]')) = []; %remove the dot
    name = strcat(p1,'_',p2,'_',p3);
end

