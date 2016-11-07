function [ new_data ] = availability(data,trials)
%AVAILABILITY 
    
    if trials == 0
        for i = 1:size(data,1)
            data{i,7} = 0;
        end
        new_data = data;
        return;
    end
    
    for i = 1:size(data,1)
        if isnan(data{i,3}) ||... %id
           isnan(data{i,4}) ||... %group
           isnan(data{i,5}) ||... %session
           data{i,6} == true %exclude
            data{i,7} = 0;
        else
            data{i,7} = 1;
        end
    end
    %check days/trials
    if trials > 0
        subdata = cell2mat(data(:,[2,3,7]));
        ses = length(unique(subdata(:,1)));
        for i = 1:ses 
            remaining = find(subdata(:,1) == i & subdata(:,3) == i);
            unique_ids = unique(subdata(remaining,2));
            for j = 1:length(unique_ids)
                count = find(subdata(remaining,2) == unique_ids(j));
                if length(count) ~= trials
                    %the rows will session = i and id = unique_ids(j)
                    %will have availability = 0
                    for c = 1:size(data,1)
                        if data{c,2} == i && data{c,3} == unique_ids(j);
                            data{c,7} = 0;
                        end
                    end    
                end
            end
        end
    end
    new_data = data;
end

