function export_num_of_clusters(path,data,varargin)
%EXPORT_NUM_OF_CLUSTERS exports the table data (number of clusters,
%error percentage, undefined percentage and coverage percentage to a CSV
%file.

% data: Nx4 double array, other columns will be excluded

    % full path = folder specified by the user + file name
    fname = 'num_of_clusters.csv';
    full_path =  strcat(path,'/',fname);
    
    % create the header
    header = {'Clusters','Error%','Undefined%','Coverage%'};
    
    % merge the data with the header into a table
    data2 = num2cell(data); 
    data2 = [header;data2(:,1:4)];
    data2 = cell2table(data2);
    
    % write table to file
    writetable(data2,full_path,'WriteVariableNames',0);
    
    % generate simple graphs (no error bars)
    if ~isempty(varargin)
        if isequal(varargin{1},'graphs')
            names = {'num_of_clusters_error','num_of_clusters_undefined','num_of_clusters_coverage'};
            labels = {'Error %','Undefined %','Coverage %'};
            for i = 1:3
                figure;
                plot(data(:,1),data(:,i+1),'-k');
                xlabel('Number of clusters');
                ylabel(labels{i});
                xlim([min(data(:,1)) max(data(:,1))]);
                set(gca, 'XTick', min(data(:,1)):5:max(data(:,1)));
                % get the configurations from the configs file
                [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
                set(gca, 'LineWidth', LineWidth, 'FontName', FontName, 'FontSize', FontSize); 
                export_figure(gcf,strcat(path,'/'),names{i},Export, ExportStyle);
            end    
        end
    end    
            
end

