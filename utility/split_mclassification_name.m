function [error,labels,segments,seg_length,seg_overlap,merging,iterations,special] = split_mclassification_name(mclassification)
%SPLIT_MCLASSIFICATION_NAME returns the parts of a Mclassification full
%path or folder

    error = 1;
    labels = '';
    segments = '';
    seg_length = '';
    seg_overlap = '';
    merging = '';
    iterations = '';
    special = '';    

    % in case we have the whole path
    name = strsplit(mclassification,{'\','/'});
    if isempty(name)
        name = mclassification;
    else
        name = name{end};
    end
    options = strsplit(name,'_');
    if isempty(options)
        disp('Wrong specified path or folder.')
        return
    end
    if ~isequal(options{1},'class')
        disp('Wrong specified path or folder.')
        return
    end
    
    try
        labels = options{2};
        segments = options{3};
        seg_length = options{4};
        seg_overlap = options{5};
        % for mclassification:
        if length(options) > 5
            merging = options{6};
            iterations = options{7};
            special = options{8};
        end
    catch
        disp('Wrong specified path or folder.')
        return
    end
    error = 0;
end

