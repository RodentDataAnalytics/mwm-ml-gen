function results_confusion_matrix(segmentation_configs,classification_configs,folds)
% Computes the confusion matrix for the classification of segments.
% Values are the total number of missclassifications for a N-fold
% cross-validation of the clustering algorithm
        
    fn = fullfile(strcat(segmentation_configs.OUTPUT_DIR,'\'), 'confusion_matrix.mat');

    % get classifier object
    classif = classification_configs.SEMISUPERVISED_CLUSTERING;
    defaults_clusters = classification_configs.DEFAULT_NUMBER_OF_CLUSTERS;

    % perform a N-fold cross-validation
    % folds = 10;
    res = classif.cluster_cross_validation(defaults_clusters, 'Folds', folds);

    % take the "total confusion matrix"    
    cm = res.results(1).confusion_matrix;
    for i = 2:folds
        cm = cm + res.results(i).confusion_matrix;
    end
    tags = res.results(1).classes;

    % save data
    save(fn, 'tags', 'cm');   
    
    disp('Tags:');
    for i = 1:length(tags)
        fprintf('%s\n', tags{1,i}{1,2});
    end
        
    fprintf('\nConfusion matrix:\n');    
    cm        
end