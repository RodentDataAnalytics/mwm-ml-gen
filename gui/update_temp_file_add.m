function update_temp_file_add(data_indexes,seg_num,new_str,tmp_data,tag_dropValue,temp)
%UPDATE_TEMP_FILE_ADD

    exist_idx = find(data_indexes == seg_num);
    if isempty(exist_idx) % if we do not have this segment
        new_str = strsplit(new_str);
        % create a new line
        [rows,cols] = size(tmp_data{1,1});
        tmp_data{1,1}{rows+1,cols} = '';
        % add seg_num and tag
        tmp_data{1,1}{end,1} = num2str(seg_num);
        tmp_data{1,1}{end,2} = new_str;
    else %if we have this segment
        % go to the specific line
        line = tmp_data{1,1}(exist_idx,:);
        for i = 1:length(line)
            % find the first gap and add the new tag
            if isequal(line{1,i},'')
                line{1,i} = tag_dropValue;
                break
            % if we have reached the end then append    
            elseif i==length(line)
                line{1,i+1} = tag_dropValue;
                break
            end    
        end    
        % add the line back to the tmp_data
        if length(line) == size(tmp_data{1,1},2)
            tmp_data{1,1}(exist_idx,:) = line;
        else % if case the line have grown
            dif = length(line)-size(tmp_data{1,1},2);
            for i = 1:dif
                [rows,cols] = size(tmp_data{1,1});
                tmp_data{1,1}{rows,cols+1} = '';
            end
            tmp_data{1,1}(exist_idx,:) = line;
        end
    end
    % save updated table to the temp file
    tmp_data = cell2table(tmp_data{1,1});
    writetable(tmp_data,temp,'WriteVariableNames',0);
end

