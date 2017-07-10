function data = read_cv_file(fn)
%READ_CV_FILE reads the cross_validation.csv file
    fileID = fopen(fn);
    header_line = fgetl(fileID);
    fclose(fileID);
    header_line = strsplit(header_line,',');
    fmt = repmat('%s ',[1,length(header_line)]);
    fileID = fopen(fn);
    data = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
    data=data{1};
    fclose(fileID);
    
    data = data(2:end,:);
    data = str2double(data);
end

