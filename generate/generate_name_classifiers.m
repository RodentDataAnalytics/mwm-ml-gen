function [name] = generate_name_classifiers(classification_configs)
%GENERATE_NAME_CLASSIFIERS returns the number of segments, the number of
%given labels and the default number of clusters as a string separated by
%'_'

    p1 = num2str(size(classification_configs.FEATURES,1));
    p2 = num2str(length(classification_configs.SEMISUPERVISED_CLUSTERING.non_empty_labels_idx));
    p3 = num2str(classification_configs.DEFAULT_NUMBER_OF_CLUSTERS);
    name = strcat(p1,'_',p2,'_',p3);
end

