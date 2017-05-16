function [ id, pts, error ] = parse_data(fn, animal_id, rec_time, centre_x, centre_y)
%PARSE_DATA gets the data of interest from file
% id = double or NaN in case of error
% pts = Nx3 double array which contains NaN in caseof error

    %Initialize
    error = 0;
    id = NaN;
    pts = [NaN NaN NaN];
    
    %Read the file
    [~, ~, ext] = fileparts(fn);
    if isequal(ext,'.CSV') || isequal(ext,'.csv')
        [data, row, col, ~, ~, ~] = read_ethovision(fn, rec_time, centre_x, centre_y);
    elseif isequal(ext,'.XLSX') || isequal(ext,'.xlsx')
        [data, row, col, ~, ~, ~] = read_ethovision_xlsx(fn, rec_time, centre_x, centre_y);
    elseif isequal(ext,'.TXT') || isequal(ext,'.txt')
        [data, row, col, ~, ~, ~] = read_ethovision_txt(fn, rec_time, centre_x, centre_y);
    else
        error = 2;
        return;
    end

    %First find the id
    i = 1;
    while i <= size(data,1)
        str = strsplit(animal_id,',');
        %check each string separated by comma
        for j = 1:length(str)
            %if you found it convert it to double or into a numeric value
            if isequal(data{i,1},str{j})
                id = str2double(data{i,2});
                if isnan(id) % not a number
                    id_ = double(data{i,2}); %double array
                    id_ = num2str(id_); %char with gaps
                    id_ = regexprep(id_,'[^\w'']',''); %remove gaps
                    id = str2double(id_); %turn to double 
                    i = size(data,1);
                    break;
                end          
            end
        end    
        i = i+1;
    end
    if isempty(id)
        id = NaN;
        error = 1;
    end    

    %Then find time,x,y
    if isnan(row) || isnan(col)
        pts = [NaN NaN NaN];
        error = 1;
        return;
    end
    
    pts = [];
    for i = row+1:size(data,1)
        % extract time, X and Y coordinates
        if isnumeric(data{i,col})
            T = data{i,col};
        else    
            T = sscanf(data{i,col}, '%f');
        end 
        if isnumeric(data{i,col+1})
            X = data{i,col+1};
        else    
            X = sscanf(data{i,col+1}, '%f');
        end    
        if isnumeric(data{i,col+2})
            Y = data{i,col+2};
        else    
            Y = sscanf(data{i,col+2}, '%f');
        end    
        % discard missing samples
        if ~isempty(T) && ~isempty(X) && ~isempty(Y)
            pts = [pts; T X Y];
        end
    end  
    if isempty(pts)
        pts = [NaN NaN NaN];
        error = 1;
    elseif ~isempty(find(isnan(pts)))
        pts = [NaN NaN NaN];
        error = 1;
    end    
end

