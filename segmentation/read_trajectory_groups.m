function [ trajectory_groups ] = read_trajectory_groups( fn )
%READ_TRAJECTORY_GROUPS Loads a csv file which contains
% animals ids and animals groups.
% Input csv files have variable number of columns and their format is
% as follows: 
%     column_1 = animal_id, column_2 = animal group,
%     column_3 = animal_id, column_4 = animal group, etc.
%     were each duo of columns represents one experimental set.
    
    file = fopen(fn);
    
    % Count the number of columns
    line = textscan(fgetl(file),'%s','Delimiter',',');
    num_cols = length(line{1});
    fclose(file);
    % Determine if csv file is correct (number of columns should be even)
    if ~isequal(mod(num_cols,2),0)
        error('read_trajectory_groups:InvalidFileFormat',['The input file ',fn,' is invalid']);
    end
    
    % Format specifier
    format = repmat('%s ',[1,num_cols]);

    % Read data
    fopen(fn);
    row_data = textscan(file,format,'CollectOutput',num_cols,'Delimiter',',');
    fclose(file);
    
    % Compute number of data per set
    count_rows = zeros(1,num_cols/2);
    k=1;
    for i = 1:2:num_cols
        for j = 1:length(row_data{1,1})
            if ~strcmp(row_data{1,1}(j,i),'')
               count_rows(k) = count_rows(k)+1;
            else
               break;
            end
        end
        k=k+1;
    end    
    
    % Create the output
    trajectory_groups = {};
    k=1;
    for i = 1:2:num_cols
        data = zeros(count_rows(k),2);
        for j = 1:length(data)
            data(j,1) = str2double(row_data{1,1}(j,i));
            data(j,2) = str2double(row_data{1,1}(j,i+1));
        end
        trajectory_groups{k,1} = data;
        k=k+1;
    end      
    
end

