function [ res, res1st ] = cross_validation_exe( classif, segmentation_configs, idx, folds, labels_path, nclusters, options, features, LABELLING_MAP, CLASSIFICATION_TAGS, segments)
%CROSS_VALIDATION_EXE Summary of this function goes here
%   Detailed explanation goes here
    
    res = [];
    res1st = [];
    
    % Build the partitions
    cv = cvpartition(idx, 'k', folds);
    
    for j = 1:cv.NumTestSets
        
        % Use subset of data
        training = zeros(1, classif.nlabels);
        training(idx(cv.training(j))) = 1;
        test = zeros(1, classif.nlabels);
        test(idx(cv.test(j))) = 1;  
        
        % Use data for the cross-validation instead of labels
%         if isequal(options,'data')
%             features(idx(cv.test(j)),:) = [];
%             LABELLING_MAP(idx(cv.test(j))) = [];
%             classif = semisupervised_clustering(segments,features,LABELLING_MAP,CLASSIFICATION_TAGS,0);
%             training = ones(1, length(classif.non_empty_labels_idx));
%             test = ones(1, classif.nlabels);
%         end          

        % Execute classification
        [tmp, tmp2] = classif.internal_cluster(nclusters, training, test);
        res = [res, tmp];
        res1st = [res1st, tmp2];

        % In case data had been used rebuild the classifier object
%         if isequal(options,'data')
%             features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:end-3);
%             load(labels_path);
%             classif = semisupervised_clustering(segments,features,LABELLING_MAP,CLASSIFICATION_TAGS,0);
%         end    
    end
    
    % Collect the results
    res = clustering_cv_results(res);
    res1st = clustering_cv_results(res1st);
end

