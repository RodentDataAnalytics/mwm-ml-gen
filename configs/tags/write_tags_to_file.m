function write_tags_to_file(data,ppath)
%WRITE_TAGS_TO_FILE writes tags to tags.txt

    %Fix header
    header = {'ABBREVIATION','DESCRIPTION','ID','COLOR1','COLOR2','COLOR3','LINESTYLE','KEY','SPECIAL'};
    data = [header ; data];

    %Cell array to table
    data = cell2table(data);
    
    %Save table to file
    writetable(data,ppath,'WriteVariableNames',0);
end

