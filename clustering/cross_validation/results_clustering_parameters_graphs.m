function results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering)
%RESULTS_CLUSTERING_PARAMETERS_GRAPHS generates and exports the
% results_clustering_parameters graphs

    DETAILED_GRAPH = 1;

    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    ci_fac = 1.96/sqrt(length(nc));

    % classification errors (cross-validation)    
    f = figure;
    set(f,'Visible','off');
    hold on
    y = arrayfun( @(x) 100*x.mean_perrors, res1bare);
    error = arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare);
    shade_errorbars(nc,y,error,'LineWidth',LineWidth);
    %errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res1bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare), 'k-', 'LineWidth', LineWidth);                       
    title('Classification errors');
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% errors', 'FontSize', FontSize, 'FontName', FontName);            
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    export_figure(f, output_path, 'num_of_clusters_error', Export, ExportStyle);
    delete(f);
    
    % classification errors (cross-validation true)    
    f = figure;
    set(f,'Visible','off');
    hold on
    y = arrayfun( @(x) 100*x.mean_perrors_true, res1bare);
    error = arrayfun( @(x) 100*x.sd_perrors_true*ci_fac, res1bare);
    shade_errorbars(nc,y,error,'LineWidth',LineWidth);
    %errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res1bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare), 'k-', 'LineWidth', LineWidth);                       
    title('Classification errors');
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% errors', 'FontSize', FontSize, 'FontName', FontName);            
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    export_figure(f, output_path, 'num_of_clusters_error_true', Export, ExportStyle);
    delete(f);    
    
    if DETAILED_GRAPH
        % classification errors: phase 1 (cross-validation) 
        f = figure;
        set(f,'Visible','off');
        hold on
        y = arrayfun( @(x) 100*x.mean_perrors, res2bare);
        error = arrayfun( @(x) 100*x.sd_perrors*ci_fac, res2bare);
        shade_errorbars(nc,y,error,'LineWidth',LineWidth);
        title('Classification errors (phase 1)');
        %errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res2bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res2bare), 'k:', 'LineWidth', LineWidth);                           
        title('Classification errors (phase 1)');
        xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
        ylabel('% errors', 'FontSize', FontSize, 'FontName', FontName);            
        set(f, 'Color', 'w');
        set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
        box off;
        export_figure(f, output_path, 'num_of_clusters_error_phase_1', Export, ExportStyle);
        delete(f);    
        
        % classification errors: phase 1 (cross-validation true) 
        f = figure;
        set(f,'Visible','off');
        hold on
        y = arrayfun( @(x) 100*x.mean_perrors_true, res2bare);
        error = arrayfun( @(x) 100*x.sd_perrors_true*ci_fac, res2bare);
        shade_errorbars(nc,y,error,'LineWidth',LineWidth);
        title('Classification errors (phase 1)');
        %errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res2bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res2bare), 'k:', 'LineWidth', LineWidth);                           
        title('Classification errors (phase 1)');
        xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
        ylabel('% errors', 'FontSize', FontSize, 'FontName', FontName);            
        set(f, 'Color', 'w');
        set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
        box off;
        export_figure(f, output_path, 'num_of_clusters_error_phase_1_true', Export, ExportStyle);
        delete(f);          
    end
    
    % percentage of unknown segments
    f = figure;
    set(f,'Visible','off');
    hold on
    y = arrayfun( @(x) 100*x.mean_punknown, res1);
    error = arrayfun( @(x) 100*x.sd_punknown*ci_fac, res1);
    shade_errorbars(nc,y,error,'LineWidth',LineWidth);    
    %errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res1),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res1), 'k-', 'LineWidth', LineWidth);                       
    hold on;
    plot(nc, arrayfun( @(x) 100*x.punknown, res3), 'k*');   
    title('Percentage of unknown segments');
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% undefined', 'FontSize', FontSize, 'FontName', FontName);            
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    export_figure(f, output_path, 'num_of_clusters_undefined', Export, ExportStyle);
    delete(f);
    
    % percentage of unknown segments: phase 1
    if DETAILED_GRAPH
        f = figure;
        set(f,'Visible','off');
        hold on
        y = arrayfun( @(x) 100*x.mean_punknown, res2);
        error = arrayfun( @(x) 100*x.sd_punknown*ci_fac, res2);
        shade_errorbars(nc,y,error,'LineWidth',LineWidth);     
        %errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res2),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res2), 'k:', 'LineWidth', LineWidth);                             
        title('Percentage of unknown segments (phase 1)');
        xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
        ylabel('% undefined', 'FontSize', FontSize, 'FontName', FontName);            
        set(f, 'Color', 'w');
        set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
        export_figure(f, output_path, 'num_of_clusters_undefined_phase_1', Export, ExportStyle);
        delete(f);    
    end
   
    % percentage of the full swimming paths that are covered by at least
    % one segment of a known class
    f = figure;
    set(f,'Visible','off');
    title('Full trajectories coverage');
    plot( nc, covering.*100,  'k-', 'LineWidth', LineWidth);                       
    xlabel('N_{clus}', 'FontSize', FontSize, 'FontName', FontName);
    ylabel('% coverage', 'FontSize', FontSize, 'FontName', FontName);        
    set(f, 'Color', 'w');
    set(gca, 'FontSize', FontSize, 'LineWidth', LineWidth, 'FontName', FontName);
    box off;
    export_figure(f, output_path, 'num_of_clusters_coverage', Export, ExportStyle);    
    delete(f);

    % final number of clusters
    if DETAILED_GRAPH
        f = figure;
        set(f,'Visible','off');
        hold on
        y = arrayfun( @(i) res1(i).mean_nclusters - nc(i), 1:length(res1));
        error = arrayfun( @(x) x.sd_nclusters*ci_fac, res1);
        shade_errorbars(nc,y,error,'LineWidth',LineWidth);          
        %errorbar( nc, arrayfun( @(i) res1(i).mean_nclusters - nc(i), 1:length(res1)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res1), 'k-', 'LineWidth', 1.5);                       
        hold on;
        y = arrayfun( @(i) res2(i).mean_nclusters - nc(i), 1:length(res2));
        error = arrayfun( @(x) x.sd_nclusters*ci_fac, res2);
        shade_errorbars(nc,y,error,'LineWidth',LineWidth);         
        %errorbar( nc, arrayfun( @(i) res2(i).mean_nclusters - nc(i), 1:length(res2)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res2), 'k:', 'LineWidth', 1.5);                           
        set(gca, 'Xtick', [50, 100, 150, 200]);  
        title('Final number of clusters');
        xlabel('N_{clus}', 'FontSize', 10);
        ylabel('\DeltaN_{clus}', 'FontSize', 10);            
        set(f, 'Color', 'w');
        set(gca, 'FontSize', 10, 'LineWidth', 1.5);
        box off;
        export_figure(f, output_path, 'final_num_of_clusters', Export, ExportStyle); 
        delete(f);
    end
end

