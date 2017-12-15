function [varargout] = results_clustering_parameters(segmentation_configs,labels_path,graph,output_path,varargin)
% Generates three figures indicating the impact of the number of clusters 
% on the clustering performance for a set of N computed segments:
% 1. Percentage of classification errors.
% 2. Percentage of segments belonging to clusters that could not be mapped
%    unambiguously to a single class.
% 3. Percentage of the full swimming paths that are covered by at least 
%    one segment of a known class.
% The calculated data from the clustering proceedures are also saved.

% PARAMETERS:
% Segmentation object
% Path of the labels CSV file
% 0/1: don't generate/generate graphs

% Optional: min number of clusters
%           max number of clusters
%           increment

    WAITBAR = 1;
    DISPLAY = 1;
    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};         
        elseif isequal(varargin{i},'DISPLAY')
            DISPLAY = varargin{i+1};     
        end
    end
    
    % Iterations
    min_num = 1;
    max_num = 10;
    step = 1;
    % Updated code
    if ~isempty(varargin)
        min_num = varargin{1};
        max_num = varargin{2};
        step = varargin{3};
    end    

    % Required info from segmentation object
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
    
    % generate unique id
    segs = num2str(size(features,1));
    a = [];
    for i = 1:10
        temp = num2str(size(find([LABELLING_MAP{:}]==i-2),2));
        a = [a, temp];
    end 
    a = [segs,a];
    
    % run multiple clusterings with different target number of clusters
    ptest = 0;
    res1 = [];
    res2 = []; 
    res3 = [];
    nc = [];
    test_set = [];      
    covering = [];  
    
    if WAITBAR
        h = waitbar(0,'Loading...','Name','Clustering');
    end
    
    for i = min_num:step:max_num
        % original code
        if min_num == 1 && max_num == 10 && step == 1
            %n = 20 + i*10;
            n = i*10;
            nc = [nc, n];
        % updated code    
        else    
            n = i;
            nc = [nc, n];
        end    
               
        % get classifier object
        classif = semisupervised_clustering(segments,features,LABELLING_MAP,CLASSIFICATION_TAGS,0);
                
        if isempty(test_set)
            if ptest > 0          
                fn = fullfile(output_path, sprintf('test_set%d.mat', n));
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
        fn = fullfile(output_path, sprintf('clustering_%d_%s.mat', n,a));
        if exist(fn ,'file')
            if DISPLAY
                fprintf('\nData for %d number of clusters (two-phase clustering) found. Loading data...\n', n);
            end
            load(fn);
        else        
            if DISPLAY
                fprintf('\nData for %d number of clusters (two-phase clustering) not found. Computing...\n', n);
            end
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
        fn = fullfile(output_path, sprintf('clustering_all_%d_%s.mat', n,a));
        if exist(fn ,'file')
            if DISPLAY
                fprintf('\nData for %d number of clusters (clustering using all the constraints) found. Loading data...\n', n);
            end
            load(fn);
        else   
            if DISPLAY
                fprintf('\nData for %d number of clusters (clustering using all the constraints) not found. Computing...\n', n);
            end
            res = classif.cluster(n);
            save(fn, 'res');
        end        
        res3 = [res3, res];
        covering = [covering, res.coverage(feature_length)]; 
        if WAITBAR
            waitbar(i/max_num);
        end
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
    if WAITBAR
        delete(h);    
    end
end
