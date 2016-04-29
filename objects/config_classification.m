classdef config_classification < handle
    
    properties(GetAccess = 'public', SetAccess = 'protected')  
        LABELLING_MAP = [];
        FEATURES = [];
        ALL_TAGS = [];
        CLASSIFICATION_TAGS = [];
        CLASSIFICATION = [];
    end
    
    methods
        %% CONSTRUCTOR %%
        function inst = config_classification(processed_user_input)
            
            % Setup
            load(processed_user_input{1,1}{1,2});
            segments = segmentation_configs.SEGMENTS;
            features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:8);
            labels_path = processed_user_input{1,1}{1,1};
            inst.FEATURES = segmentation_configs.FEATURES_VALUES_SEGMENTS;
            
            % Tag trajectories/segments if data are available
            [~, inst.LABELLING_MAP, inst.ALL_TAGS, inst.CLASSIFICATION_TAGS] = setup_tags(segments,labels_path);
            
            % Semisupervised Clustering
            res = semisupervised_clustering(segments,features,inst.LABELLING_MAP,inst.CLASSIFICATION_TAGS,0);
            inst.CLASSIFICATION = res.cluster(processed_user_input{1,2},0); 
        end
    end
end

