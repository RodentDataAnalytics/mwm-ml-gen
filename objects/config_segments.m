classdef config_segments < handle

    properties(GetAccess = 'public', SetAccess = 'protected')
        %% USER INPUT SETTINGS %%
        % Experiment Settings (Common Settings)
        COMMON_SETTINGS = {};
        % Experiment Properties (Common Properties)
        COMMON_PROPERTIES = {};
        % Trajectory groups data
        TRAJECTORY_GROUPS = [];
        % Trajectories data directory
        TRAJECTORIES_DIR = [];
        % Output directory        
        OUTPUT_DIR = [];
        % Cache directory
        CACHE = [];
        % Features Cache directory
        CACHE_FEATURES = [];
        % Return path
        RETURN_PATH = [];

        %% GENERATING DATA %%
        TRAJECTORIES = [];
        SEGMENTS = [];
        PARTITION = [];
        CUM_PARTITIONS = [];
        FEATURES_VALUES_TRAJECTORIES = [];
        FEATURES_VALUES_SEGMENTS = [];
    end
    
    methods
        %% CONSTRUCTOR %%
        function inst = config_segments(processed_user_input)
            
            % Trajectory groups
            inst.TRAJECTORY_GROUPS = read_trajectory_groups(processed_user_input{1,1}{1,1});

            % Experiment Settings (Common Settings)
            inst.COMMON_SETTINGS = {'Sessions',processed_user_input{1,2}(1),...
                       'TrialsPerSession',processed_user_input{1,2}(2),...
                       'TrialType',ones(1,sum(processed_user_input{1,2}{1,2})),...
                       'TrialTypesDescription',processed_user_input{1,2}(3),...
                       'GroupsDescription',processed_user_input{1,2}(4)};

            % Experiment Properties (Common Properties)
            inst.COMMON_PROPERTIES = {'TRIAL_TIMEOUT ',processed_user_input{1,3}(1),...
                         'CENTRE_X',processed_user_input{1,3}(2),...
                         'CENTRE_Y',processed_user_input{1,3}(3),...
                         'ARENA_R',processed_user_input{1,3}(4),...
                         'PLATFORM_X',processed_user_input{1,3}(5),...
                         'PLATFORM_Y',processed_user_input{1,3}(6),...
                         'PLATFORM_R',processed_user_input{1,3}(7),...
                         'PLATFORM_PROXIMITY_RADIUS',processed_user_input{1,3}(8),...
                         'LONGEST_LOOP_EXTENSION',processed_user_input{1,3}(9)};
            
            % Trajectories data directory 
            inst.TRAJECTORIES_DIR = processed_user_input{1,1}{2};         
            % Output directory
            inst.OUTPUT_DIR = processed_user_input{1,1}{3};
            % Cache directory
            inst.CACHE = create_cache_dir(1,inst.OUTPUT_DIR);
            % Features directory
            inst.CACHE_FEATURES = create_cache_dir(2,inst.OUTPUT_DIR);

            % Load trajectories
            inst.TRAJECTORIES = load_data(inst);
            
            % Segmentation
            [inst.SEGMENTS, inst.PARTITION, inst.CUM_PARTITIONS, inst.RETURN_PATH] = inst.TRAJECTORIES.partition(inst.CACHE, 2, 'trajectory_segmentation_constant_len', processed_user_input{1,4}{1}, processed_user_input{1,4}{2});
            
            % Compute Features
            inst.FEATURES_VALUES_TRAJECTORIES = compute_features(inst.TRAJECTORIES.items, features_list, inst.COMMON_PROPERTIES, inst.CACHE_FEATURES);
            inst.FEATURES_VALUES_SEGMENTS = compute_features(inst.SEGMENTS.items, features_list, inst.COMMON_PROPERTIES, inst.CACHE_FEATURES);   
        end
    end
    
end