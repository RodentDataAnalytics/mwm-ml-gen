function [ data, row, col, time, x, y ] = read_ethovision_txt( fn, rec_time, centre_x, centre_y )
%READ_ETHOVISION same as read_ethovision.m but for .txt files

    %Count the number of columns
    [num_cols, ~] = count_columns(fn ,';');
    
    %Create a format specifier of the correct size
    fmt = repmat('%q ',[1,num_cols]); % %q skips "..."
    
    %Read data
    fileID = fopen(fn);
    data = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',delimiter);
    data=data{1};
    fclose(fileID);
    
    %Locate the rec_time, centre_x, centre_y
    [row, col, time, x, y] = locate_coordinates(data, rec_time, centre_x, centre_y, num_cols);
end