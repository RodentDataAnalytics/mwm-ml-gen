function [error,labels,segments,num_of_clusters] = split_classifier_name(classifier)
%SPLIT_CLASSIFIER_NAME returns the parts of a classifier's full path or
%folder

    error = 1;
    labels = '';
    segments = '';
    num_of_clusters = '';
  
    name = strsplit(classifier,{'\','/'});

    if isempty(name)
        name = classifier;
    else
        name = name{end};
    end
    options = strsplit(name,'_');
    if isempty(options)
        disp('Wrong specified path or folder.')
        return
    end
    if ~isequal(options{1},'classification')
        disp('Wrong specified path or folder.')
        return
    end
    
    try
        labels = options{4};
        segments = options{3};
        num_of_clusters = strsplit(options{5},'.');
        num_of_clusters = num_of_clusters{1};
    catch
        disp('Wrong specified path or folder.')
        return
    end
    error = 0;
end

