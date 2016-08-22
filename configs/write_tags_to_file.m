function write_tags_to_file(data)
%WRITE_TAGS_TO_FILE writes tags to tags.txt

    %Fix header
    header = {'ABBREVIATION','DESCRIPTION','ID','WEIGHT','COLOR1','COLOR2','COLOR3','LINESTYLE'};
    for i = 1:length(header)
        data{1,i} = header{1,i};
    end    
    %Fix color to cells
    for i = 2:size(data,1)
        data{i,end} = data{i,6};
        color = data{i,5};
        for j = 1:3
            data{i,4+j} = color(j);
        end
    end    
    
    %Cell array to table
    data = cell2table(data);
    
    %Save table to file
    if ~isdeployed
        path = fullfile(pwd,'configs','tags.txt');
        writetable(data,path,'WriteVariableNames',0);
    else
        path = fullfile(ctfroot,'configs','tags.txt');
        writetable(data,path,'WriteVariableNames',0);
    end  

end

