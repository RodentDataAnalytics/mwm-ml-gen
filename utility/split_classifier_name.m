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
    tmp = 0;
    if ~isequal(options{1},'classification') 
        tmp = 1;
        if ~isequal(options{1},'class') 
            disp('Wrong specified path or folder.')
            return
        end
    end
    
    if tmp == 1
        try
            labels = options{2};
            segments = options{3};
            num_of_clusters = '';
        catch
            disp('Wrong specified path or folder.')
            return
        end
    elseif tmp == 0
        try
            labels = options{4};
            segments = options{3};
            num_of_clusters = strsplit(options{5},'.');
            num_of_clusters = num_of_clusters{1};
        catch
            disp('Wrong specified path or folder.')
            return
        end        
    end
    error = 0;
end

