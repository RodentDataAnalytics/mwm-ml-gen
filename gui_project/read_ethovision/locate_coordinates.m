function [row, col, time, x, y] = locate_coordinates(data, rec_time, centre_x, centre_y, num_cols)
%LOCATE_COORDINATES locates the rec_time, centre_x, centre_y

    %Initialize
    time = []; 
    x = [];
    y = [];
    idx = 0;
    row = NaN;
    col = NaN;
    
    %Check if file is correct
    %if data{N,1} = numeric => data{N,:} = numerics
    for i = 1:size(data,1)
        if ~isnan(str2double(data{i,1})) || isnumeric(data{i,1})
            idx = i;
            break;
        end
    end 
    if idx == 0
        return;
    end    
    %All the cells from idx needs to be mumeric
    for i = idx:size(data,1)
        if isnan(str2double(data{i,1})) && ~isnumeric(data{i,1})
            return;
        end
    end    
    
    %Find the line containing rec_time, centre_x, centre_y
    %These fields have to follow this order
    a = strsplit(rec_time,',');
    b = strsplit(centre_x,',');
    c = strsplit(centre_y,',');
    for i = idx-1:-1:1
        for j = 1:num_cols
            for k1 = 1:length(a)
                a_ = strfind(data{i,j},a{k1});
                if ~isempty(a_)
                    time = a{k1};
                    for k2 = 1:length(b)
                        b_ = strfind(data{i,j+1},b{k2});
                        if ~isempty(b_)
                            x = b{k2};
                            for k3 = 1:length(c)
                                c_ = strfind(data{i,j+2},c{k3});
                                if ~isempty(c_)
                                    y = c{k3};
                                    row = i;
                                    col = j;
                                    return;
                                end    
                            end 
                        end
                    end
                end
            end
        end
    end
end

