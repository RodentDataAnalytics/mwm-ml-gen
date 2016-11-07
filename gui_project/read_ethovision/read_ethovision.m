function [ data, row, col, time, x, y ] = read_ethovision( fn, rec_time, centre_x, centre_y )
%READ_ETHOVISION Loads native Ethovision format file into cell array
% for later post_processing. Input CSV files have variable sized headers 
% and variable number of column widths.

%INPUT:
%fn = full file name
%rec_time, centre_x, centre_y = may contain multiple comma-separated values

%OUTPUT
%data = NxM cell containing the CSV data
%row, col = indicate the line of rec_time, centre_x, centre_y by pointing 
%           on the cell containing the rec_time. They are NaN in case the 
%           file is incorrect
%time, x, y = in case multible (comma separated) arguments have been given
%             for rec_time, centre_x, centre_y, return also the correct
%             ones

% Author: Mike Croucher
% Edited & updated by: Avgoustinos Vouros

    %Count number of columns
    %SOMETIMES IT DOES NOT WORK:
    %fileID = fopen(fn);
    %header_line = fgetl(fileID);
    %num_cols = length(strfind(header_line,',')) + 1;
    %fclose(fileID);
    %REPLACED WITH:
    [num_cols, ~] = count_columns(fn ,',');
    
    %Create a format specifier of the correct size
    fmt = repmat('%s ',[1,num_cols]);

    %Read data
    fileID = fopen(fn);
    data = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
    data=data{1};
    fclose(fileID);
    
    %Locate the rec_time, centre_x, centre_y
    [row, col, time, x, y] = locate_coordinates(data, rec_time, centre_x, centre_y, num_cols);
end  
