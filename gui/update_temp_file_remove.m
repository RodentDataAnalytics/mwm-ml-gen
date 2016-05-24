function update_temp_file_remove(data_indexes,seg_num,new_str,tmp_data,temp)
%UPDATE_TEMP_FILE_REMOVE

    exist_idx = find(data_indexes == seg_num);
    if ~isempty(exist_idx) %if we have this segment
        % break the new_str into cells
        if ~isempty(new_str{1,1})
            % split it on spaces
            new_str = strsplit(new_str{1,1},' ');
            % remove empty cells
            new_str = new_str(~cellfun('isempty',new_str));  
            % put the number
            new_str = [num2str(seg_num), new_str];  
            % make the new_str equal to the size(2) of tmp_data
            if length(new_str) < size(tmp_data{1,1},2);
                new_str{1,size(tmp_data{1,1},2)} = '';
            end 
            % replace the specific line of tmp_data with new_str     
            tmp_data{1,1}(exist_idx,:) = new_str;
            % save updated table to the temp file
            tmp_data = cell2table(tmp_data{1,1});
            writetable(tmp_data,temp,'WriteVariableNames',0);            
        else
            % means that it was the only tag thus remove the whole line
            new_str{1,size(tmp_data{1,1},2)} = '';
            tmp_data{1,1}(exist_idx,:) = new_str; 
            % save updated table to the temp file
            tmp_data = cell2table(tmp_data{1,1});
            tmp_data(exist_idx,:) = []; % remove the gap row
            writetable(tmp_data,temp,'WriteVariableNames',0);  
        end       
    else % if we do not have this segment return
        return
    end    
end
