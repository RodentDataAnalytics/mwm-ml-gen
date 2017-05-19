function [error,numbers,removed] = check_num_of_clusters(str,labels)
%CHECK_NUM_OF_CLUSTERS
    
    THRESHOLD = 300;
    %see how many of the tags we have really used
    tags = length(unique(cell2mat(labels)));

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
            if numbers(i) < tags
                numbers(i) = NaN;
                removed = [removed,i];
            elseif numbers(i) > THRESHOLD
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

