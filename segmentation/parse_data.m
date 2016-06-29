function [ processed_data ] = parse_data(fn, animal_id, rec_time, centre_x, centre_y)
%PARSE_DATA gets the data of interest from file

    %Read the csv or xlsx file
    [~, ~, ext] = fileparts(fn);
    if isequal(ext,'.CSV') || isequal(ext,'.csv')
        [data, header_idx] = read_ethovision(fn, rec_time, centre_x, centre_y);
    elseif isequal(ext,'.XLSX') || isequal(ext,'.xlsx')
        [data, header_idx] = read_ethovision_xlsx(fn, rec_time, centre_x, centre_y);
    end
    
    %Initialize
    id = '';
    skipped_file = '';
    time = {};
    x = {};
    y = {};
    damaged_file = 0;
    pts = [];
    flag = '';

    %First find id
    i = 1;
    while i <= size(data,1)
        if isequal(data{i,1},animal_id)
            if isnumeric(data{i,2})
                id = data{i,2};
            else    
                id = sscanf(data{i,2}, '%d');
            end    
        end
        try 
            flag = str2num(data{i,1});
        catch
            flag = data{i,1};
        end
        if ~isempty(flag)
            %if we are here then we should have the id
            if isempty(id)
                %indicate which file was skipped
                skipped_file = fn;
            end
            break;
        end
        i = i+1;
    end

    %Then find time,x,y
    k = 1;
    while k <= size(data,2)
        j = header_idx;
        %if you find either time/x/y take the rest row
        if isequal(data{header_idx,k},rec_time)
            i=1;
            while j <= size(data,1)
                time{i,1} = data{j,k};
                j=j+1;
                i=i+1;
            end    
        elseif isequal(data{header_idx,k},centre_x)
            i=1;
            while j <= size(data,1)
                x{i,1} = data{j,k};
                j=j+1;
                i=i+1;
            end    
        elseif isequal(data{header_idx,k},centre_y)
            i=1;
            while j <= size(data,1)
                y{i,1} = data{j,k};
                j=j+1;
                i=i+1;
            end     
        end
        %if time,x,y are not empty => we have the data thus stop
        if ~isempty(time) && ~isempty(x) && ~isempty(y)
            break;
        end 
        k = k+1;
    end
    
    % if time,x,y weren't found then the file is damaged
    % if length(x) ~= length(y) ~= length(t) then file is damaged
    if isempty(time) || isempty(x) || isempty(y) ||...
       length(time)~=length(x) || length(time)~=length(y) || length(x)~=length(y)
        damaged_file = 1;
    else
        for i = 1:length(time)
            % extract time, X and Y coordinates
            if isnumeric(time{i, 1})
                T = time{i, 1};
            else    
                T = sscanf(time{i, 1}, '%f');
            end 
            if isnumeric(x{i, 1})
                X = x{i, 1};
            else    
                X = sscanf(x{i, 1}, '%f');
            end    
            if isnumeric(y{i, 1})
                Y = y{i, 1};
            else    
                Y = sscanf(y{i, 1}, '%f');
            end    
            % discard missing samples
            if ~isempty(T) && ~isempty(X) && ~isempty(Y)
                pts = [pts; T X Y];
            end
        end
    end    
    
    processed_data = {skipped_file,id,damaged_file,pts};
end

