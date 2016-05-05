function results_clustering_parameters(segmentation_configs,labels_path)
% Generates three figures indicating the impact of the number of clusters 
% on the clustering performance for a set of N computed segments:
% 1. Percentage of classification errors.
% 2. Percentage of segments belonging to clusters that could not be mapped
%    unambiguously to a single class.
% 3. Percentage of the full swimming paths that are covered by at least 
%    one segment of a known class.
% The calculated data from the clustering proceedures are also saved.

    segments = segmentation_configs.SEGMENTS;
    features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:8);
    feature_length = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,10);

    % Tag trajectories/segments if data are available
    [~, LABELLING_MAP, ~, CLASSIFICATION_TAGS] = setup_tags(segments,labels_path);

    % run multiple clusterings with different target number of clusters
    ptest = 0;
    res1 = [];
    res2 = []; 
    res3 = [];
    nc = [];
    test_set = [];      
    covering = [];  
        
    for i = 1:10
        n = 20 + i*10;
        nc = [nc, n];
               
        % get classifier object
        classif = semisupervised_clustering(segments,features,LABELLING_MAP,CLASSIFICATION_TAGS,0);
                
        if isempty(test_set)
            if ptest > 0          
                fn = fullfile(strcat(segmentation_configs.OUTPUT_DIR,'\'), sprintf('test_set.mat', n));
                if exist(fn ,'file')
                    load(fn);
                else                
                    test_set = zeros(1, classif.nlabels);
                    idx = 1:classif.nlabels;
                    test_set(idx(randsample(length(idx), floor(length(idx)*ptest)))) = 1;
                    save(fn, 'test_set');
                end
            else
                test_set = [];
            end
        end
        
        % i) two-phase clustering (default)        
        % see if we already have the data
        fn = fullfile(strcat(segmentation_configs.OUTPUT_DIR,'\'), sprintf('clustering_n%d.mat', n));
        if exist(fn ,'file')
            load(fn);
        else            
            [res, res1st] = classif.cluster_cross_validation(n, 'Folds', 10, 'TestSet', test_set);
            save(fn, 'res', 'res1st');
        end 
        res.compress;
        res1st.compress;
        
        res1 = [res1, res];
        res2 = [res2, res1st];
                
        % ii) clustering using all the constraints
        % see if we already have the data
        classif.two_stage = 1;        
        fn = fullfile(strcat(segmentation_configs.OUTPUT_DIR,'\'), sprintf('clustering_all_constr_%d.mat', n));
        if exist(fn ,'file')
            load(fn);
        else            
            res = classif.cluster(n);
            save(fn, 'res');
        end        
        res3 = [res3, res];
        covering = [covering, res.coverage(feature_length)];      
    end
    
    % export data
    save(fullfile(strcat(segmentation_configs.OUTPUT_DIR,'\'), 'clustering_parameters.mat'), 'res1', 'res2', 'res3');
    
    % remap the classes as to not invalidate mixed clusters
    % because we want to compare the clustering errors
    res1bare = [];
    res2bare = [];    
    for i = 1:length(res1)
        res1bare = [res1bare, res1(i).remap_clusters('DiscardMixed', 0)];
    end
    for i = 1:length(res2)
        res2bare = [res2bare, res2(i).remap_clusters('DiscardMixed', 0)];
    end
 
    % classification errors (cross-validation)    
    figure(77);
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
    export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'\'), 'clusters_dep_err');

    % percentage of unknown segments
    figure(78);
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
    export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'\'), 'clusters_dep_undef');
    
    % final number of clusters
    figure(79);
    errorbar( nc, arrayfun( @(i) res1(i).mean_nclusters - nc(i), 1:length(res1)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res1), 'k-', 'LineWidth', 1.5);                       
    hold on;
    errorbar( nc, arrayfun( @(i) res2(i).mean_nclusters - nc(i), 1:length(res2)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res2), 'k:', 'LineWidth', 1.5);                           
    set(gca, 'Xtick', [50, 100, 150, 200]);  
    xlabel('N_{clus}', 'FontSize', 10);
    ylabel('\DeltaN_{clus}', 'FontSize', 10);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', 10, 'LineWidth', 1.5);
    h3 = gca;
    box off;
    export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'\'), 'clusters_dep_deltan');

    % percentage of the full swimming paths that are covered by at least
    % one segment of a known class
    figure(80);
    ci_fac = 1.96/sqrt(length(nc));
    plot( nc, covering*100,  'k-', 'LineWidth', 1.5);                       
    xlabel('N_{clus}', 'FontSize', 10);
    ylabel('% coverage', 'FontSize', 10);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', 10, 'LineWidth', 1.5, 'YLim', [80, 100]);
    h1 = gca;
    box off;
    export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'\'), 'clusters_dep_coverage');
end
