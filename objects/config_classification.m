classdef config_classification < handle
    
    properties(GetAccess = 'public', SetAccess = 'public')  
        LABELLING_MAP = [];
        % computed features
        FEATURES = [];
        % All available tags
        ALL_TAGS = [];
        % Tags used for the classification
        CLASSIFICATION_TAGS = [];
        % Default number of clusters
        DEFAULT_NUMBER_OF_CLUSTERS = [];
        % Semisupervised clustering results
        SEMISUPERVISED_CLUSTERING = [];
        % Classification results
        CLASSIFICATION = [];
    end
    
    methods
        %% CONSTRUCTOR %%
        function inst = config_classification(segmentation_configs,DEFAULT_NUMBER_OF_CLUSTERS,LABELLING_MAP,ALL_TAGS,CLASSIFICATION_TAGS)
            % Setup
            segments = segmentation_configs.SEGMENTS;
            features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:8);
            inst.FEATURES = segmentation_configs.FEATURES_VALUES_SEGMENTS;
            inst.DEFAULT_NUMBER_OF_CLUSTERS = DEFAULT_NUMBER_OF_CLUSTERS;
            inst.LABELLING_MAP = LABELLING_MAP;
            inst.ALL_TAGS = ALL_TAGS;
            inst.CLASSIFICATION_TAGS = CLASSIFICATION_TAGS;
            
            % Semisupervised Clustering
            res = semisupervised_clustering(segments,features,inst.LABELLING_MAP,inst.CLASSIFICATION_TAGS,0);
            inst.SEMISUPERVISED_CLUSTERING = res;
            %last argument: 0 = mpckmeans, 1 = kmeans
            inst.CLASSIFICATION = res.cluster(inst.DEFAULT_NUMBER_OF_CLUSTERS,0); 
        end
    end
end

