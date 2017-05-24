function error = create_pvalues_table(table,class_tags,fpath,varargin)
%CREATE_PVALUES_TABLE creates a csv file containing all the p-values
%generated from the multiple classifications of a classifier group

    error = 1;
    % convert to double array
    table_ = cell2mat(table);
    avg_table = zeros(size(table_,1),1);
    % score (how many less than 0.05)
    for i = 1:size(table_,1)
        count = length(find(table_(i,:) < 0.05));
        avg_table(i) = count;
    end
    
    % Confidence intervals figure
    create_pvalues_confidence_intervals(avg_table,size(table,2),class_tags,fpath,varargin{:});
    
    avg_table = num2cell(avg_table);
    % convert to cell array and add the avg
    table_ = num2cell(table_);
    table_ = [avg_table,table_];
    % form the rows and the columns
    row = cell(1,size(table_,2));
    row{1} = strcat('score','/',num2str(size(table_,2)-1));
    column = cell(1,size(table_,1)+1);
    column{1} = 'p-values';
    for i = 2:size(table_,2)
        row{i} = strcat('class',num2str(i-1));
    end
    for i = 1:size(table_,1)
        if i <= length(class_tags)
            column{i+1} = class_tags{i}{2};
        else
            column{i+1} = 'Direct Finding';
        end
    end    
    table_ = [row;table_];
    table_ = [column',table_];
    if length(column) == 2
        table_{2,1} = 'transitions';
    end
    table_ = cell2table(table_);
    try
        fid = fopen(fpath,'w');
        fclose(fid);      
        % save the labels to the file
        writetable(table_,fpath,'WriteVariableNames',0);
        error = 0;
    catch
        return;
    end
end

