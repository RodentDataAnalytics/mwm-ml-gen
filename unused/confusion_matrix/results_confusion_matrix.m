function results_confusion_matrix(classification_configs,folds,output_dir)
% Computes the confusion matrix for the classification of segments.
% Values are the total number of missclassifications for a N-fold
% cross-validation of the clustering algorithm
        
    fn = fullfile(output_dir, 'confusion_matrix.mat');
    fn2 = fullfile(output_dir, 'Confusion_matrix.txt');

    % get classifier object
    classif = classification_configs.SEMISUPERVISED_CLUSTERING;
    defaults_clusters = classification_configs.DEFAULT_NUMBER_OF_CLUSTERS;

    % perform a N-fold cross-validation
    res = classif.cluster_cross_validation(defaults_clusters, 'Folds', folds);

    % take the "total confusion matrix"    
    cm = res.results(1).confusion_matrix;
    for i = 2:folds
        cm = cm + res.results(i).confusion_matrix;
    end
    tags = res.results(1).classes;
    
    % NaN values
    for i = 1:size(cm,1)
        for j = 1:size(cm,2)
            if isnan(cm)
                cm(i,j) = 0;
            end
        end
    end    

    % save data
    save(fn, 'tags', 'cm');   
    disp('Tags:');
    for i = 1:length(tags)
        fprintf('%s\n', tags{1,i}{1,2});
    end  
    fprintf('\nConfusion matrix:\n');    
    cm        
    
    % save to file
    fileID = fopen(fn2,'wt');
    for i = 1:length(tags)
        fprintf(fileID,'%d. %s\n', i, tags{1,i}{1,2});
    end
    fprintf(fileID, '\n');
    for i=1:size(cm,1)
        fprintf(fileID, '%d ', cm(i,:));
        fprintf(fileID, '\n');
    end
    fclose(fileID);
    
end