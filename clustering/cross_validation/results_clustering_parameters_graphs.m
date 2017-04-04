function results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering)
%RESULTS_CLUSTERING_PARAMETERS_GRAPHS generates and exports the
% results_clustering_parameters graphs

    DETAILED_GRAPH = 1;

    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;

    % classification errors (cross-validation)    
    f = figure;
    set(f,'Visible','off');
    title('Classification errors');
    ci_fac = 1.96/sqrt(length(nc));
    errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res1bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare), 'k-', 'LineWidth', LineWidth);                       
    hold on;
    if DETAILED_GRAPH
        errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res2bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res2bare), 'k:', 'LineWidth', LineWidth);                           
    end
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% errors', 'FontSize', FontSize, 'FontName', FontName);            
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    box off;
    export_figure(f, output_path, 'num_of_clusters_error', Export, ExportStyle);
    delete(f);
    
    % percentage of unknown segments
    f = figure;
    set(f,'Visible','off');
    title('Percentage of unknown segments');
    errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res1),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res1), 'k-', 'LineWidth', LineWidth);                       
    hold on;
    if DETAILED_GRAPH
        errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res2),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res2), 'k:', 'LineWidth', LineWidth);                           
    end
    plot(nc, arrayfun( @(x) 100*x.punknown, res3), 'k*');   
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% undefined', 'FontSize', FontSize, 'FontName', FontName);            
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    box off;
    export_figure(f, output_path, 'num_of_clusters_undefined', Export, ExportStyle);
    delete(f);
   
    % percentage of the full swimming paths that are covered by at least
    % one segment of a known class
    f = figure;
    set(f,'Visible','off');
    title('Full trajectories coverage');
    ci_fac = 1.96/sqrt(length(nc));
    plot( nc, covering.*100,  'k-', 'LineWidth', LineWidth);                       
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% coverage', 'FontSize', FontSize, 'FontName', FontName);        
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    box off;
    export_figure(f, output_path, 'num_of_clusters_coverage', Export, ExportStyle);    
    delete(f);

    % final number of clusters
    %figure(79);
    %title('Final number of clusters');
    %errorbar( nc, arrayfun( @(i) res1(i).mean_nclusters - nc(i), 1:length(res1)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res1), 'k-', 'LineWidth', 1.5);                       
    %hold on;
    %errorbar( nc, arrayfun( @(i) res2(i).mean_nclusters - nc(i), 1:length(res2)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res2), 'k:', 'LineWidth', 1.5);                           
    %set(gca, 'Xtick', [50, 100, 150, 200]);  
    %xlabel('N_{clus}', 'FontSize', 10);
    %ylabel('\DeltaN_{clus}', 'FontSize', 10);            
    %set(gcf, 'Color', 'w');
    %set(gca, 'FontSize', 10, 'LineWidth', 1.5);
    %h3 = gca;
    %box off;
    %export_figure(f, output_path, 'final_num_of_clusters', Export, ExportStyle); 
    %delete(f);
end

