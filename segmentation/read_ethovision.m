function [ data, count ] = read_ethovision( fn, rec_time, centre_x, centre_y )
%READ_ETHOVISION Loads native Ethovision format file into cell array
% for later post_processing by read_trajectory
% Input csv files have variable sized headers and variable number of column
% widths
% Author: Mike Croucher
% Edited: Avgoustinos Vouros

%Determine properties of input file
fileID = fopen(fn);
%The last header line needs to contain user's defined 'time' 'x' 'y'
count = 1;
header_line = fgetl(fileID);
a = strfind(header_line, rec_time);
b = strfind(header_line, centre_x);
c = strfind(header_line, centre_y);
while isempty(a) && isempty(b) && isempty(c) && ~feof(fileID)
    count = count+1;
    header_line = fgetl(fileID);
    a = strfind(header_line, rec_time);
    b = strfind(header_line, centre_x);
    c = strfind(header_line, centre_y);
end
%The next line of data contains the columns we are attempting to count
%data_line = fgetl(fileID);
data_line = header_line;
fclose(fileID);

%How many columns in this data_line?
data_line = textscan(data_line,'%s','Delimiter',',');
num_cols = length(data_line{1});

%Create a format specifier of the correct size
fmt = repmat('%s ',[1,num_cols]);

%Read data
fileID = fopen(fn);
data = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
data=data{1};
fclose(fileID);


end

