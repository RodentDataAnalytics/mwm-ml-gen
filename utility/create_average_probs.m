function error = create_average_probs(values,class_tags,fpath,groups)
%CREATE_AVERAGE_PROBS Summary of this function goes here
%   Detailed explanation goes here
    
    % Compute the average
    vals = zeros(size(values{1}{1},1),size(values{1}{1},2));
    vals_ = cell(1,length(values{1}));
    for i = 1:length(values{1})
        for v = 1:length(values)
            groupv = values{v}{i};
            vals = vals + groupv;
        end
        vals_{i} = vals./length(values);
        vals = zeros(size(values{1}{1},1),size(values{1}{1},2));
    end
    % Arrange the table
    row = cell(1,length(class_tags));
    for i = 1:length(row)
        row{i} = class_tags{i}{2};
    end
    column = cell(1,length(class_tags)+1);
    column{1} = '';
    for i = 2:length(column)
        column{i} = class_tags{i-1}{2};
    end   
    table_ = {};
    for i = 1:length(vals_)
        table = {};
        table = [table;num2cell(vals_{i})];
        table = [row; table];
        table = [column',table];
        table{1} = strcat('group',num2str(groups(i)));
        table_{i} = table;
    end       
    % Form the table
    if length(table_) > 1
        table_ = [table_{1};table_{2}];
    else
        table_ = table_{1};
    end
    table_ = cell2table(table_);
    % Create file and write the table
    try
        fid = fopen(fpath,'w');
        fclose(fid);      
        % save the labels to the file
        writetable(table_,fpath,'WriteVariableNames',0);
        error = 0;
    catch
        error = 1;
        return;
    end
end

