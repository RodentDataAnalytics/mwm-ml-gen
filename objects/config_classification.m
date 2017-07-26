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
        % Results only from the first clustering stage
        first_stage_clustering = [];
        % Skipped K (skipped if flag = 0)
        flag = [1,1];
    end
    
    methods
        %% CONSTRUCTOR %%
        function inst = config_classification(segmentation_configs,DEFAULT_NUMBER_OF_CLUSTERS,LABELLING_MAP,ALL_TAGS,CLASSIFICATION_TAGS,varargin)
           
            UNSUPERVISED = 0;
            
            for i = 1:length(varargin)
                if isequal(varargin{i},'UNSUPERVISED')
                    UNSUPERVISED = varargin{i+1};                               
                end
            end

            % Setup
            segments = segmentation_configs.SEGMENTS;
            features = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,1:end-3);
            inst.FEATURES = segmentation_configs.FEATURES_VALUES_SEGMENTS;
            inst.DEFAULT_NUMBER_OF_CLUSTERS = DEFAULT_NUMBER_OF_CLUSTERS;
            inst.LABELLING_MAP = LABELLING_MAP;
            inst.ALL_TAGS = ALL_TAGS;
            inst.CLASSIFICATION_TAGS = CLASSIFICATION_TAGS;
            
            % Semisupervised Clustering
            res = semisupervised_clustering(segments,features,inst.LABELLING_MAP,inst.CLASSIFICATION_TAGS,0);
            inst.SEMISUPERVISED_CLUSTERING = res;
            %last argument (f_unsupervised): 
            %0 = mpckmeans, 1 = first step without labels
            [inst.CLASSIFICATION, inst.first_stage_clustering, inst.flag] = res.cluster(inst.DEFAULT_NUMBER_OF_CLUSTERS,UNSUPERVISED); 
        end
    end
end

