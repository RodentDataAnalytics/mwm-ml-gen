classdef config_classification < handle
    
    properties(GetAccess = 'public', SetAccess = 'protected')  
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
        % Output directory        
        OUTPUT_DIR = [];
    end
    
    methods
        %% CONSTRUCTOR %%
        function inst = config_classification(processed_user_input)
            
            % Setup
            load(processed_user_input{1,1}{1,2});
            inst.OUTPUT_DIR = segmentation_configs.OUTPUT_DIR;
            segments = segmentation_configs.SEGMENTS;
            features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:8);
            labels_path = processed_user_input{1,1}{1,1};
            inst.FEATURES = segmentation_configs.FEATURES_VALUES_SEGMENTS;
            inst.DEFAULT_NUMBER_OF_CLUSTERS = processed_user_input{1,2};
            
            % Tag trajectories/segments if data are available
            [~, inst.LABELLING_MAP, inst.ALL_TAGS, inst.CLASSIFICATION_TAGS] = setup_tags(segments,labels_path);
            
            % Semisupervised Clustering
            res = semisupervised_clustering(segments,features,inst.LABELLING_MAP,inst.CLASSIFICATION_TAGS,0);
            inst.SEMISUPERVISED_CLUSTERING = res;
            inst.CLASSIFICATION = res.cluster(inst.DEFAULT_NUMBER_OF_CLUSTERS,0); 
        end
    end
end

