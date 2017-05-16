function data_fields2 = parse_txt_adv(input_file)
% This script makes it possible for MATLAB to read UTF-16 Little Endian 
% files. Original solution was proposed by Walter Roberson (see link below:
%https://uk.mathworks.com/matlabcentral/answers/267176-read-and-seperate-csv-data#answer_209938)

% Requires the detect_UTF_encoding.m created by the same author.

% Script turned into a function by Avgoustinos Vouros.
% Change: data_fields2 is a cell array containing both the header and the 
% data of the input file.

    [file_encoding, bytes_per_char, BOM_size, bytes2char] = detect_UTF_encoding(input_file);
    if isempty(file_encoding)
       error('No usable input file');
    end

    fid = fopen(input_file,'rt');
    fread(fid, [1, BOM_size], '*uint8');   %skip the Byte Order Mark
    thisbuffer = fgets(fid);
    extra = mod(length(thisbuffer), bytes_per_char);
    if extra ~= 0
      %in little-endian modes, newline would be found in first byte and the 0's after need to be read
      thisbuffer = [thisbuffer, fread(fid, [1, bytes_per_char - extra], '*uint8')];
    end
    thisline = bytes2char(thisbuffer);

    data_cell = textscan(thisline, '%s', 'delimiter', ',');   %will ignore the end of lines
    header_fields = reshape(data_cell{1}, 1, []);
    num_field = length(header_fields);
    thisbuffer = fread(fid, [1 inf], '*uint8');
    extra = mod(length(thisbuffer), bytes_per_char);
    if extra ~= 0
      thisbuffer = [thisbuffer, zeros(1, bytes_per_char - extra, 'uint8')];
    end
    thisline = bytes2char(thisbuffer);
    fmt = repmat('%s', 1, num_field);
    data_cell = textscan(thisline, fmt, 'delimiter', ',');
    data_fields_text = horzcat(data_cell{:});
    data_fields = data_fields_text;
    
    % Add the header to the final output
    header_fields2 = header_fields{1};
    data_fields2 = [header_fields2;data_fields];
end
