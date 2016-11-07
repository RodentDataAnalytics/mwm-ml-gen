function [ data, row, col, time, x, y ] = read_ethovision_xlsx(fn, rec_time, centre_x, centre_y)
%READ_ETHOVISION_XLSX same as read_ethovision.m but for .xlsx files
%Works only for Windows OS.

    %[num,txt,raw]
    [~, ~, data] = xlsread(fn);
    num_cols = size(data,2);
    
    %Locate the rec_time, centre_x, centre_y
    [row, col, time, x, y] = locate_coordinates(data, rec_time, centre_x, centre_y, num_cols);
end

