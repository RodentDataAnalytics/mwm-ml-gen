classdef semisupervised_clustering < handle
    %CLUSTERING_PARAMETERS Input for the semisupervised_clustering
    %functions
    
    properties(GetAccess = 'public', SetAccess = 'public')
        % number of features
        nfeatures = 0;
        % feature values
        features = [];
        % labels - has to be a vector of integers of same length as the
        % features
        labels = []; 
        % non-empty labels only
        nlabels = [];
        % number of external labels (these are used only to guide the
        % clustering)
        nexternal_labels = 0;
        % non-empty labels index 
        non_empty_labels_idx = [];
        % optional -> just to map the labels to classes
        classes = [];
        nclasses = 0;
        segments = [];
    end
        
    properties(GetAccess = 'public', SetAccess = 'public')
        % use two-stage clustering
        two_stage = 1;
        % force must-link constraints (not recommended)
        must_link = 0;
        % maximum distance between two elements to define constraints
        constraints_max_distance = 0.25;
        % percentage of constraints to use for the clustering (for testing
        % purposes)
        pconstraints = 1.;
    end
    
    properties(GetAccess = 'public', SetAccess = 'public')
        % create an array of integers in which each bit represents one
        % label; this will be needed bellow to test if any two sets of labels
        % have a common member (using 'intersect' is just absurdely slow)    
        labels_binary = [];        
    end
    
    methods        
        function inst = semisupervised_clustering(seg, feat, lbls, classes_in, next)            
            % Constructor         
            inst.segments = seg;
            if nargin > 2
                inst.classes = classes_in;
                inst.nclasses = length(classes_in);
            end               
            if nargin > 3
                inst.nexternal_labels = next;
            end
            inst.nfeatures = size(feat, 2);
            % normalize features            
            inst.features = feat ./ repmat( max(feat) - min(feat), size(feat, 1), 1);            
            inst.labels = lbls;
            if isequal(lbls,-1)
                return;
            end
            
            % look for non-empty labels
            for i = 1:length(lbls)
                tmp = lbls{i};
                if tmp ~= -1
                    inst.non_empty_labels_idx = [inst.non_empty_labels_idx, i];
                    inst.labels_binary = [inst.labels_binary, int32(0)];
                    for j = 1:length(tmp)
                        inst.labels_binary(end) = bitset(inst.labels_binary(end), tmp(j) + 1);
                    end
                end
            end
            inst.nlabels = length(inst.non_empty_labels_idx); 
        end
        
        function [res, res1st, flag] = cluster(inst, nclusters, test_p)
            % run the clustering
            mask = ones(1, length(inst.non_empty_labels_idx));
            
            if nargin > 2 && test_p > 0.
                n = length(inst.non_empty_labels_idx);
                mask(randsample(1:n, floor(n*test_p))) = 0;
            end 
            
            % run clusterer using a subset of the labels for training and
            % all of them for validation
            if nargout > 1
                % get also the results for the 1st stage clustering
                [res, res1st, flag] = inst.internal_cluster(nclusters, mask, ones(1, inst.nlabels));                
            else
                [res,~,flag] = inst.internal_cluster(nclusters, mask, ones(1, inst.nlabels));
            end
        end
        
        function [res, res1st] = cluster_cross_validation(inst, nclusters, varargin)
            res = [];
            if nargout > 1
                res1st = [];
            end
            
            [folds, ptraining, nruns, test_set] = process_options(varargin, ...
                'Folds', 10, 'TrainingPercentage', 0, 'Runs', 1, 'TestSet', [] ...
            ); 
                        
            idx = 1:inst.nlabels;
            if ~isempty(test_set)
                % remove test set from available labels for training
                idx = idx(test_set == 0);
            else
                test_set = ones(1, inst.nlabels);
            end
                       
            for t = 1:nruns
                if ptraining == 0
                    % use 
                    cv = cvpartition(idx, 'k', folds);

                    for j = 1:cv.NumTestSets % perforn a N-fold stratified cross-validation                                        
                        % perform classifcation using only a subset of the labels
                        training = zeros(1, inst.nlabels);
                        training(idx(cv.training(j))) = 1;
                        test = zeros(1, inst.nlabels);
                        test(idx(cv.test(j))) = 1;

                        if nargout > 1
                            % get also the results for the 1st stage
                            % clustering
                            [tmp, tmp2] = inst.internal_cluster(nclusters, training, test);
                            res = [res, tmp];
                            res1st = [res1st, tmp2];
                        else
                            res = [res, inst.internal_cluster(nclusters, training, test)];
                        end                        
                    end
                else
                    % take ptraining 
                    training_set = zeros(1, inst.nlabels);
                    training_set(idx(randsample(length(idx), floor(length(idx)*ptraining)))) = 1;
                    
                    if nargout > 1
                        % get also the results for the 1st stage
                        % clustering
                        [tmp, tmp2] = inst.internal_cluster(nclusters, training_set, test_set);
                        res = [res, tmp];
                        res1st = [res1st, tmp2];
                    else
                        res = [res, inst.internal_cluster(nclusters, training_set, test_set)];
                    end                                        
                end
            end
            res = clustering_cv_results(res);
            if nargout > 1
                res1st = clustering_cv_results(res1st);
            end
        end
    end            
        
    methods%(Access = private)                                        
        function [res, res1st, flag] = internal_cluster(inst, nclusters, training_set, test_set)            
            if size(inst.features,1) == size(inst.non_empty_labels_idx,2)
                % we have label all the segments
                flag = [0,0];
                res1st = [];
                class_idx = zeros(1,length(inst.labels));
                for i = 1:length(inst.labels)
                    tmp = inst.labels{i};
                    if length(tmp) > 1
                        class_idx(i) = 0;
                    else
                        class_idx(i) = inst.labels{i};
                    end
                end
                res = clustering_results(inst.segments, length(inst.classes), inst.labels, training_set, test_set, inst.nexternal_labels, 0, class_idx, [], [], [], inst.classes);        
                return
            end
            % divide the data into labelled/unlabelled elements
            % move labelled items to the front   
            labels_idx = inst.non_empty_labels_idx(training_set == 1);       
            bin_labels = inst.labels_binary(training_set == 1);
            lbls = inst.labels(labels_idx);            
            unlabelled = setdiff(1:length(inst.labels), labels_idx);    
            % mapping of the reordered features back to the original sequence
            results_map = zeros(1, length(inst.labels));    
            results_map(labels_idx) = 1:length(labels_idx);
            results_map(unlabelled) = (length(labels_idx) + 1):length(inst.labels);
            % reorded features -> first labelled then unlabelled items
            reordered_feat = [inst.features(labels_idx, :); inst.features(unlabelled, :)];         

            %% build list of constraints    
            constr = [];
            for j = 1:length(labels_idx)
                for k = (j + 1):length(labels_idx)          
                    % determine if both sets of labels match (if at least one element
                    % is present in both sets)
                    % don't use 'intersect' for this -> its implementation is
                    % really really slow
                    if bitand(bin_labels(j), bin_labels(k)) 
                        if ~inst.two_stage && inst.must_link && sqrt(sum((inst.features(labels_idx(j), :) - inst.features(labels_idx(k), :)).^2)) < inst.constraints_max_distance                       
                           % MUST-LINK constraint - lower index followed by higher one
                           constr = [constr; min(j, k), max(j, k)];                                      
                        end              
                    elseif sqrt(sum((inst.features(labels_idx(j), :) - inst.features(labels_idx(k), :)).^2)) < inst.constraints_max_distance
                        % CANNOT-LINK constraint - other way around
                        constr = [constr; max(j, k), min(j, k)];
                    else
                        continue;
                    end
                end
            end
            
            if inst.pconstraints < 1 
                constr = constr(randsample(size(constr, 1), floor(size(constr, 1)*inst.pconstraints)), :);
            end
            
            nconstr = length(constr);
            
            %% 1st (main stage): cluster the data
            fprintf('Clustering... (total number of constraints: %d)', size(constr, 1));
            [cluster_idx, centroids, flag] = mpckmeans(reordered_feat, constr, nclusters);
            cluster_idx = cluster_idx + 1; % mpck-means uses zero based indexes (it's Java after all) -> we want them to start at 1
            % reorder indexes again to match the input data
            cluster_idx = cluster_idx(results_map);   

            % map clusters to classes
            cluster_map = cluster_to_class(arrayfun( @(ci) sum(cluster_idx == ci), 1:nclusters), lbls, cluster_idx(labels_idx)); 
                        
            %% 2nd stage: subcluster ambigouous clusters (containing elements of more than one 
            % this is the new cluster index for sub-clusters: start at the previous
            % cluster count
            icluster = 0;    
            new_cluster_idx = zeros(1, length(cluster_idx));
            new_cluster_map = zeros(1, length(cluster_map));
            new_centroids = zeros(inst.nfeatures, length(cluster_map));
            nconstr2 = 0;
            for i = 1:nclusters
                % elements of this cluster
                sub_idx = find(cluster_idx == i);            
                % check if cluster is empty
                if ~isempty(sub_idx)
                    % non-empty cluster -> rebase elements
                    icluster = icluster + 1;
                    new_cluster_idx(sub_idx) = icluster;
                    new_cluster_map(icluster) = cluster_map(i); 
                    new_centroids(:, icluster) = centroids(:, i);
                    if inst.two_stage && cluster_map(i) == 0
                        % take labels in this cluster which are also not
                        % masked out                        
                        sub_labels = inst.labels(sub_idx);
                        sub_labels_idx = [];                        
                        sub_bin_labels = [];
                        for j = 1:numel(sub_labels)
                            tmp = sub_labels{j};
                            if tmp ~= -1
                                sub_labels_idx = [sub_labels_idx, j];
                                sub_bin_labels = [sub_bin_labels, int32(0)];
                                for k = 1:length(tmp)
                                    sub_bin_labels(end) = bitset(sub_bin_labels(end), tmp(k) + 1);
                                end                             
                            end
                        end

                        sub_labels = sub_labels(sub_labels_idx);
                           
                        unique_labels = [];
                        constr = [];
                        for j = 1:(length(sub_labels_idx) - 1)
                            for k = (j + 1):length(sub_labels_idx)            
                                if (numel(sub_labels{j}) > 1 || sub_labels{j} ~= -1) && (numel(sub_labels{k}) > 1 || sub_labels{k} ~= -1)
                                    if bitand(sub_bin_labels(j), sub_bin_labels(k))
                                        constr = [constr; min(j, k), max(j, k)];
                                        unique_labels = unique([unique_labels, intersect(sub_labels{j}, sub_labels{k})]); 
                                    else                            
                                        constr = [constr; max(j, k), min(j, k)];
                                        unique_labels = unique([unique_labels, sub_labels{j}, sub_labels{k}]);
                                    end
                                end
                            end
                        end

                        if ~isempty(unique_labels)                                                        
                            unlabelled = setdiff(1:length(sub_idx), sub_labels_idx);    
                            % mapping of the reordered features back to the original sequence
                            results_map = zeros(1, length(sub_idx));    
                            results_map(sub_labels_idx) = 1:length(sub_labels_idx);
                            results_map(unlabelled) = (length(sub_labels_idx) + 1):length(sub_idx);
                            % reorded features -> first labelled then unlabelled items
                            reordered_feat = [inst.features(sub_idx(sub_labels_idx), :); inst.features(sub_idx(unlabelled), :)];         
                            feat_std = reordered_feat ./ repmat( max(reordered_feat) - min(reordered_feat), size(reordered_feat, 1), 1);
                            reordered_feat = feat_std;        

                            % sub-clustering      
                            nsub = max(2, length(unique_labels));

                            for s = nsub:2*nsub
                                fprintf('**** Partitioning cluster %d into %d sub-clusters... ****\n', i, s);

                                [sub_cluster_idx, sub_centroids, f] = mpckmeans(reordered_feat, constr, s);
                                sub_cluster_idx = sub_cluster_idx + 1;
                                % reorder indexes agaion to match the input data
                                sub_cluster_idx = sub_cluster_idx(results_map);   

                                sub_cluster_map = cluster_to_class(arrayfun( @(ci) sum(sub_cluster_idx == ci), 1:s), sub_labels, sub_cluster_idx(sub_labels_idx));

                                if sum(sub_cluster_map) > 0
                                    nconstr2 = nconstr2 + length(constr);
                                    first = 1;
                                    for j = 1:s
                                        if sum(sub_cluster_idx == j) > 0
                                            % for the first sub-cluster reuse the previous cluster number
                                            if ~first
                                                icluster = icluster + 1;
                                            else
                                                first = 0;                                        
                                            end
                                            new_cluster_idx(sub_idx(sub_cluster_idx == j)) = icluster;                                    
                                            new_cluster_map(icluster) = sub_cluster_map(j);           
                                            new_centroids(:, icluster) = sub_centroids(:, j);
                                        end
                                    end
                                    break;
                                end
                            end
                        end                       
                    end
                end
            end

            % see if we want the intermediate 1st stage results            
            if nargout > 1
                class_idx = zeros(1, length(cluster_idx));
                for i = 1:icluster
                    sel = find(cluster_idx == i);        
                    if ~isempty(sel)
                        class_idx(sel) = cluster_map(i);
                    end
                end

                res1st = clustering_results( inst.segments ...
                                           , length(inst.classes) ...
                                           , inst.labels(inst.nexternal_labels + 1:end) ...
                                           , training_set, test_set ...
                                           , inst.nexternal_labels ...
                                           , nconstr, class_idx ...
                                           , cluster_idx, cluster_map, centroids, inst.classes);             
            end
                        
            cluster_idx = new_cluster_idx;
            cluster_map = new_cluster_map;
            centroids = new_centroids;

            class_idx = zeros(1, length(cluster_idx));
            for i = 1:icluster
                sel = find(cluster_idx == i);        
                if ~isempty(sel)
                    class_idx(sel) = cluster_map(i);
                end
            end
                                    
            % create return object
            try % to be skipped if two_stage = 0
                flag = [flag,f];
            catch
            end
            res = clustering_results(inst.segments, length(inst.classes), inst.labels, training_set, test_set, inst.nexternal_labels, [nconstr, nconstr2], class_idx, cluster_idx, cluster_map, centroids, inst.classes);             
        end    
    end
end