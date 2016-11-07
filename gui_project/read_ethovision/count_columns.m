function [num_cols, index] = count_columns(fn, delimiter)
%COUNT_COLUMNS counts the columns of a file
%Reads the file line by line and finds the row with the most 'delimiter'.
%The number of columns will then be count(;)+1.
%Note: This line (index) will be the line containing the coordinates.

    fileID = fopen(fn);
    num_cols = 0;
    idx = 1;
    while ~feof(fileID)
        header_line = fgetl(fileID);
        header_line = strsplit(header_line,delimiter);
        if length(header_line) + 1 > num_cols
            num_cols = length(header_line) + 1;
            index = idx;
        end 
        idx = idx + 1;
    end       
    fclose(fileID);
end

