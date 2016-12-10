function [error,segments,seg_length,seg_overlap] = split_segmentation_name(segmentation)
%SPLIT_SEGMENTATION_NAME returns the parts of a segmentation full path or 
%folder

    error = 1;
    segments = '';
    seg_length = '';
    seg_overlap = '';  

    % in case we have the whole path
    name = strsplit(segmentation,{'\','/'});
    if isempty(name)
        name = segmentation;
    else
        name = name{end};
    end
    options = strsplit(name,{'_','.'});
    if isempty(options)
        disp('Wrong specified path or folder.')
        return
    end
    if ~isequal(options{1},'segmentation') || ~isequal(options{end},'mat') 
        disp('Wrong specified path or folder.')
        return
    end
    
    try
        segments = options{3};
        seg_length = options{4};
        seg_overlap = options{5};
    catch
        disp('Wrong specified path or folder.')
        return
    end
    error = 0;    
end

