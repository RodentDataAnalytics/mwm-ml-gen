classdef config_segments < handle

    properties(GetAccess = 'public', SetAccess = 'public')
        %% USER INPUT SETTINGS %%
        % Experiment Properties
        EXPERIMENT_PROPERTIES = [];
        COMMON_PROPERTIES = [];
        % Segmentation propertires
        SEGMENTATION_PROPERTIES = [];
        % Animal Groups
        TRAJECTORY_GROUPS = [];
        % Trajectories
        TRAJECTORIES = [];
        SEGMENTS = [];
        PARTITION = [];
        CUM_PARTITIONS = [];
        FEATURES_VALUES_TRAJECTORIES = [];
        FEATURES_VALUES_SEGMENTS = [];
    end
    
    methods
        %% CONSTRUCTOR %%
        function inst = config_segments(EXPERIMENT_PROPERTIES,SEGMENTATION_PROPERTIES,TRAJECTORY_GROUPS,TRAJECTORIES,TRAJ_FEAT,extra,varargin)
            
            WAITBAR = 1;
            for i = 1:length(varargin)
                if isequal(varargin{i},'WAITBAR')
                    WAITBAR = varargin{i+1};
                end
            end
            
            % Known properties
            inst.EXPERIMENT_PROPERTIES = EXPERIMENT_PROPERTIES;
            inst.COMMON_PROPERTIES = EXPERIMENT_PROPERTIES(1:18);
            for i = 1:length(inst.COMMON_PROPERTIES)
                if mod(i,2) == 0
                    value = inst.COMMON_PROPERTIES{i};
                    inst.COMMON_PROPERTIES{i} = {value};
                end
            end    
            inst.SEGMENTATION_PROPERTIES = SEGMENTATION_PROPERTIES;
            inst.TRAJECTORY_GROUPS = TRAJECTORY_GROUPS;
            inst.TRAJECTORIES = TRAJECTORIES;
            
            % Segmentation properties
            segment_length = SEGMENTATION_PROPERTIES(1);
            segment_overlap = SEGMENTATION_PROPERTIES(2);
            
            if isempty(extra)
                % Segmentation
                if WAITBAR
                    h = waitbar(0,'Segmenting trajectories...');
                end
                [inst.SEGMENTS, inst.PARTITION, inst.CUM_PARTITIONS] = inst.TRAJECTORIES.partition(2, 'trajectory_segmentation_constant_len', segment_length, segment_overlap);
                if WAITBAR
                    delete(h);
                end
                % Trajectory features
                inst.FEATURES_VALUES_TRAJECTORIES = TRAJ_FEAT;
                % Segment features
                inst.FEATURES_VALUES_SEGMENTS = compute_features(inst.SEGMENTS.items, features_list, inst.COMMON_PROPERTIES, varargin{:});  
            elseif isequal(extra,'dummy')
                inst.SEGMENTS = TRAJECTORIES;
                inst.SEGMENTS.parent = TRAJECTORIES;
                inst.PARTITION = ones(1,length(inst.SEGMENTS.items));
                inst.CUM_PARTITIONS = inst.PARTITION;
                inst.FEATURES_VALUES_TRAJECTORIES = TRAJ_FEAT;
                inst.FEATURES_VALUES_SEGMENTS = inst.FEATURES_VALUES_TRAJECTORIES;
            end    
        end
    end    
end