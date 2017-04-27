function [error,numbers,removed] = check_num_of_clusters(str,tags,labels)
%CHECK_NUM_OF_CLUSTERS
    
    %see how many of the tags we have really used
    tags = length(unique(cell2mat(labels)))-1;

    error = 1;
    numbers = [];
    removed = [];
    if isempty(str)
        error = 2;
        return;
    end
    if isempty(str2num(str))
        return
    else
        numbers = str2num(str);
        for i = 1:length(numbers)
            if numbers(i) < tags+2
                numbers(i) = NaN;
                removed = [removed,i];
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
end

