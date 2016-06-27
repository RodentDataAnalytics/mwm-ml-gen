function results_clustering_parameters_graphs(output_dir,nc,res1bare,res2bare,res1,res2,res3,covering)
%RESULTS_CLUSTERING_PARAMETERS_GRAPHS generates and exports the
% results_clustering_parameters graphs

    % classification errors (cross-validation)    
    figure(77);
    title('Classification errors');
    ci_fac = 1.96/sqrt(length(nc));
    errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res1bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare), 'k-', 'LineWidth', 1.5);                       
    hold on;
    errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res2bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res2bare), 'k:', 'LineWidth', 1.5);                           
    xlabel('N_{clus}', 'FontSize', 10);
    ylabel('% errors', 'FontSize', 10);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', 10, 'LineWidth', 1.5);
    h1 = gca;
    box off;
    export_figure(1, gcf, strcat(output_dir,'/'), 'clusters_dep_err');

    % percentage of unknown segments
    figure(78);
    title('Percentage of unknown segments');
    errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res1),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res1), 'k-', 'LineWidth', 1.5);                       
    hold on;
    errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res2),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res2), 'k:', 'LineWidth', 1.5);                           
    plot(nc, arrayfun( @(x) 100*x.punknown, res3), 'k*');   
    xlabel('N_{clus}', 'FontSize', 10);
    ylabel('% undefined', 'FontSize', 10);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', 10, 'LineWidth', 1.5);
    h2 = gca;
    box off;
    export_figure(1, gcf, strcat(output_dir,'/'), 'clusters_dep_undef');
   
    % percentage of the full swimming paths that are covered by at least
    % one segment of a known class
    figure(80);
    title('Full trajectories coverage');
    ci_fac = 1.96/sqrt(length(nc));
    plot( nc, covering.*100,  'k-', 'LineWidth', 1.5);                       
    xlabel('N_{clus}', 'FontSize', 10);
    ylabel('% coverage', 'FontSize', 10);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', 10, 'LineWidth', 1.5);
    h1 = gca;
    box off;
    export_figure(1, gcf, strcat(output_dir,'/'), 'clusters_dep_coverage');    

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
    %export_figure(1, gcf, strcat(output_dir,'/'), 'clusters_dep_deltan');

end

