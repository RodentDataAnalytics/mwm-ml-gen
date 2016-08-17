function [ data, count ] = read_ethovision_xlsx(fn, rec_time, centre_x, centre_y)
%READ_ETHOVISION_XLSX same as read_ethovision.m but for .xlsx files

    [~, ~, data] = xlsread(fn);
    count = 0;
    
    for i = 1:size(data,1)
        count = i;
        a = find(strcmp(data(i,:),rec_time));
        b = find(strcmp(data(i,:),centre_x));
        c = find(strcmp(data(i,:),centre_y));        
        if ~isempty(a) && ~isempty(b) && ~isempty(c)
            break
        end
    end    
        
end

