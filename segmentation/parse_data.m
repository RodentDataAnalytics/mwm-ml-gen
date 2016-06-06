function [ processed_data ] = parse_data(fn, animal_id, animal_group, rec_time, centre_x, centre_y)
%PARSE_DATA gets the data of interest from file

    %Read the csv file
    [data, header_idx] = read_ethovision(fn,rec_time, centre_x, centre_y);

    %Initialize
    id = '';
    group = '';
    skipped_file = '';
    time = {};
    x = {};
    y = {};
    damaged_file = 0;
    pts = [];

    %First find id,group,trial,session
    i = 1;
    while i <= size(data,1)
        if isequal(data{i,1},animal_id)
            id = sscanf(data{i,2}, '%d');
        elseif isequal(data{i,1},animal_group)
            group = sscanf(data{i,2}, '%d');
        elseif ~isempty(str2num(data{i,1}))   
            %if we are here then we should have the id,group,trial,session
            if isempty(id) || isempty(group) || isempty(trial)
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
            T = sscanf(time{i, 1}, '%f');
            X = sscanf(x{i, 1}, '%f');
            Y = sscanf(y{i, 1}, '%f');
            % discard missing samples
            if ~isempty(T) && ~isempty(X) && ~isempty(Y)
                pts = [pts; T X Y];
            end
        end
    end    
    
    processed_data = {skipped_file,id,group,damaged_file,pts};
end

