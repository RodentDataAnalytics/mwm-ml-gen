function [ indexes, labels, s] = browse_read_labels_file(path)
%BROWSE_OPEN_LABELS_FILE reads a label file and if it is in the old format
%it automatically fixes it

    indexes = 0;
    labels = {0};

    % open file and count the columns
    fid = fopen(path);
    header = fgetl(fid);
    s = header(1);
    num_cols = length(strsplit(header,','));
    % create a format specifier of the correct size
    fmt = repmat('%s ',[1,num_cols]);
    fclose(fid);
    
    % check if the file is correct
    old_format = 0;
    if ~isequal(header(1),'S')
        if ~isequal(header(1),'T')
            % check if the file has no header (old format)
            if ~isempty(str2num(header(1)))
                old_format = 1;
            else
                return
            end
        end
    end
           
    % if the file has no header it is generated using an older version,
    % thus fix it
    if old_format
        % read data (we have +1 columns)
        num_cols = num_cols+1;
        fid = fopen(path);
        fmt = repmat('%s ',[1,num_cols]);
        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
        data = data{1};
        fclose(fid);
        header = cell(1,10); % Segment + 8 strategies + undefined
        header{1} = 'Segment';
        for i = 2:num_cols
            header{i} = strcat('label',num2str(i-1));
        end
        % make the data cell array larger
        if size(data,2) < 10
            data{1,length(header)} = [];
        end
        data = [header ; data];
        data = cell2table(data);
        writetable(data,path,'WriteVariableNames',0);
    end    
    
    % re-read the file
    fid = fopen(path);
    fmt = repmat('%s ',[1,num_cols]);
    data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
    data = data{1};
    data(1,:) = [];
    fclose(fid);
    
    % get the segs indexes from temp_data
    indexes = zeros(size(data,1),1);
    labels = cell(size(data,1) , size(data,2)-1);
    for i = 1:size(data,1)
        indexes(i) = str2num(data{i,1});
        for j = 2:size(data,2) 
            if isempty(data{i,j});
                break;
            end    
            labels{i,j-1} = data{i,j};
        end
    end  
end

