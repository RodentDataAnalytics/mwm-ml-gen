function [segments,len,ovl,ppath] = get_segmentation_name(path_seg)
%SPLIT_SEGMENTATION_NAME given the full file path of a segmentation it
%returns the number of segments, the segments length, the segments overlap
%and the project path.

    [pathstr,name,~] = fileparts(path_seg);
    subname = strsplit(name,'_');
    segments = subname{3};
    len = subname{4};
    ovl = subname{5};
    ppath = fileparts(pathstr);
end

