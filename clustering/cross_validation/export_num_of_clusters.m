function export_num_of_clusters(ppath,data)
%EXPORT_NUM_OF_CLUSTERS exports the table data (number of clusters,
%error percentage, undefined percentage and coverage percentage to a CSV
%file.

% data: Nx4 double array

    % full ppath = folder specified by the user + file name
    fname = 'cross_validation.csv';
    full_ppath =  fullfile(ppath,fname);

    % create the header
    header = {'Clusters','Error%','Undefined%','Coverage%', 'Validation_Error%'};
    
    % merge the data with the header into a table
    data2 = num2cell(data); 
    data2 = [header;data2];
    data2 = cell2table(data2);
    
    % write table to file
    writetable(data2,full_ppath,'WriteVariableNames',0);  
end

