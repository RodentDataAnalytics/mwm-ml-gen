function [ varargout ] = cross_validation( segmentation_configs, labels_path, folds, clusters, output_path, options, graph)
%CROSS_VALIDATION Summary of this function goes here
%   Detailed explanation goes here

%% INITIALIZATION
    min_num = clusters(1);
    max_num = clusters(2);
    step = clusters(3);
    segments = segmentation_configs.SEGMENTS;
    features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:8);
    feature_length = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,10);
    
    % Tag trajectories/segments if data are available
    try
        load(labels_path); % loads LABELLING_MAP and CLASSIFICATION_TAGS
    catch
        errordlg('Cannot load labels file','Error');
    end
    if ~exist('LABELLING_MAP','var')
        errordlg('Wrong labels file','Error');
    end

    % Generate unique id
    segs = num2str(size(features,1));
    a = [];
    for i = 1:10
        temp = num2str(size(find([LABELLING_MAP{:}]==i-2),2));
        a = [a, temp];
    end 
    a = [segs,a];
    
    % Run multiple clusterings with different target number of clusters
    res1 = [];
    res2 = []; 
    res3 = []; 
    covering = []; 
    nc = [];
    
    %% EXECUTE

    % Get classifier object
    classif = semisupervised_clustering(segments,features,LABELLING_MAP,CLASSIFICATION_TAGS,0);
    
    res = [];
    res1st = [];

    idx = 1:classif.nlabels;
    %test_set = ones(1, inst.nlabels);
    h = waitbar(0,'Loading...','Name','Clustering');
    
    for i = min_num:step:max_num
        nclusters = i;
        nc = [nc, nclusters];
        
        % i) two-phase clustering (default)   
        fn = fullfile(output_path, sprintf('clustering_%d_%s.mat',nclusters,a));
        if exist(fn ,'file')
            fprintf('\nData for %d number of clusters (two-phase clustering) found. Loading data...\n', nclusters);
            load(fn);
        else            
            fprintf('\nData for %d number of clusters (two-phase clustering) not found. Computing...\n', nclusters);
            [res, res1st] = cross_validation_exe( classif, segmentation_configs, idx, folds, labels_path, nclusters, options, features, LABELLING_MAP, CLASSIFICATION_TAGS, segments);
            save(fn, 'res', 'res1st');
        end
        res.compress;
        res1st.compress;
        res1 = [res1, res];
        res2 = [res2, res1st];
        
        % ii) clustering using all the constraints (compute coverate) 
        fn = fullfile(output_path, sprintf('clustering_all_%d_%s.mat',nclusters,a));
        if exist(fn ,'file')
            fprintf('\nData for %d number of clusters (two-phase clustering) found. Loading data...\n', nclusters);
            load(fn);
        else            
            fprintf('\nData for %d number of clusters (two-phase clustering) not found. Computing...\n', nclusters);
            res = classif.cluster(nclusters);
            save(fn, 'res');
        end        
        res3 = [res3, res];
        covering = [covering, res.coverage(feature_length)];        
        
        waitbar(i/max_num);        
    end
    
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
     
    if graph 
        % Generate the graphs
        results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering);    
    else
        % Returns the values
        varargout{1} = nc;
        varargout{2} = res1bare;
        varargout{3} = res2bare;
        varargout{4} = res1;
        varargout{5} = res2;
        varargout{6} = res3;
        varargout{7} = covering;
    end   
    delete(h);    
    
end
