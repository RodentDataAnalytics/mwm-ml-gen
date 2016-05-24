function [tmp_data,data_indexes] = open_temp_file(temp_file)
%OPEN_TEMP_FILE 

    % get the labels
    fid = fopen(temp_file);
    f_line = fgetl(fid);
    fclose(fid);
    num_cols = length(find(f_line==','))+1;
    fmt = repmat('%s ',[1,num_cols]);
    fid = fopen(temp_file);
    tmp_data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
    fclose(fid);
    % get the segs indexes from temp_data
    data_indexes = zeros(size(tmp_data{1,1},1),1);
    for i = 1:size(tmp_data{1,1},1)
        data_indexes(i,1) = str2num(tmp_data{1,1}{i,1});
    end  

end

