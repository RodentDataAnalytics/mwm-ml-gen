function [error,numbers,removed] = check_num_of_clusters(str,labels,varargin)
%CHECK_NUM_OF_CLUSTERS
    
    K_THRESHOLD = 0;
    SKIP_SMALLER = 1;
    SKIP_SMALLER_e = 2;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'K_THRESHOLD')
            K_THRESHOLD = varargin{i+1};
        elseif isequal(varargin{i},'SKIP_SMALLER')
            SKIP_SMALLER = 1;
            SKIP_SMALLER_e = varargin{i+1};
        end
    end
    
    %see how many of the tags we have really used
    tags = unique(cell2mat(labels));
    tmp = find(tags <= 0);
    tags = length(tags) - length(tmp);

    error = 1;
    numbers = [];
    removed = [];
    
    if isempty(str)
        error = 2;
        return;
    end
    
    if ~isnumeric(str)
        numbers = str2num(str);
    else
        numbers = str;
    end
    
    if isempty(numbers)
        error = 2;
        return
    end

    for i = 1:length(numbers)
        if SKIP_SMALLER
            if numbers(i) < tags + SKIP_SMALLER_e
                removed = [removed,numbers(i)];
                numbers(i) = NaN;
            end
        end
        if numbers(i) > K_THRESHOLD && K_THRESHOLD > 0
            removed = [removed,numbers(i)];   
            numbers(i) = NaN;    
        end
    end
    % remove NaNs
    numbers(find(isnan(numbers))) = [];
    if isempty(numbers)
        return;
    else
        error = 0;
    end
end

