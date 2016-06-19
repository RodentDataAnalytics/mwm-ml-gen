function [temp_file] = create_temp_groups_file(sessions, animal_ids)
%CREATE_TEMP_GROUPS_FILE creates a temp file for storing animal ids and
%user defined animal groups

    max_ = 0;
    for i = 1:sessions
        if size(animal_ids{i},2) > max_
            max_ = size(animal_ids{i},2);
        end
    end    

    %% Create a temp file and populate it with the animal ids
    % Create title and initialize file format
    data = {};
    temp_data = {};
    header = {};
    for i = 1:sessions
        header = [header,['ID_',num2str(i)],['Group_',num2str(i)]];
        temp_data = num2str(animal_ids{i}');
        temp_data = cellstr(temp_data);
        temp_data{length(temp_data),2} = '';
        data{i,1} = temp_data;
    end
    max_ = 0;
    for i = 1:sessions
        if size(data{i},1) > max_
            max_ = size(data{i},1);
        end
    end
    data_all = [];
    for i = 1:sessions
        temp = data{i};
        temp{max_,2} = '';
        data{i} = temp;
        data_all = [data_all, temp];
    end

    Table = cell2table(data_all,'VariableNames',header);
    % Create temp file
    temp_file = [tempname '.csv'];
    fid = fopen(temp_file,'w');
    writetable(Table,temp_file);
    fclose(fid);

end

