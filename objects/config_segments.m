classdef config_segments < handle

    properties(GetAccess = 'public', SetAccess = 'public')
        %% USER INPUT SETTINGS %%
        % Files format and trajectory groups
        TRAJECTORY_GROUPS = [];
        FORMAT = cell(1,6);
        % Experiment Settings (Common Settings)
        COMMON_SETTINGS = cell(1,3);
        % Experiment Properties (Common Properties)
        COMMON_PROPERTIES = cell(1,7);
        % Output directory        
        OUTPUT_DIR = [];
        % Segmentation propertires
        SEGMENTATION_PROPERTIES = [];

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
        function inst = config_segments(processed_user_input,varargin)
            
            % File format
            inst.FORMAT{1,1} = processed_user_input{1,2}(1);
            inst.FORMAT{1,2} = processed_user_input{1,2}(2);
            inst.FORMAT{1,3} = processed_user_input{1,2}(3);
            inst.FORMAT{1,4} = processed_user_input{1,2}(4);
            
            % Animal groups
            if ~isempty(processed_user_input{1,1}{1,3})
                % if Demo
                try
                    [~,~,ext] = fileparts(processed_user_input{1,1}{3}); 
                    if isequal(ext,'.csv') || isequal(ext,'.CSV')
                        inst.TRAJECTORY_GROUPS = read_trajectory_groups(processed_user_input{1,1}{3});
                    end
                % if user data   
                catch    
                    inst.TRAJECTORY_GROUPS = processed_user_input{1,1}{3};
                end    
            end
            
            % Experiment Settings (Common Settings)
            inst.COMMON_SETTINGS = {'Sessions',processed_user_input{1,3}(1),...
                       'TrialsPerSession',processed_user_input{1,3}(2),...
                       'TrialType',ones(1,sum(processed_user_input{1,3}{1,2})),...
                       'Days',processed_user_input{1,3}(3)};

            % Experiment Properties (Common Properties)
            inst.COMMON_PROPERTIES = {'TRIAL_TIMEOUT ',processed_user_input{1,4}(1),...
                         'CENTRE_X',processed_user_input{1,4}(2),...
                         'CENTRE_Y',processed_user_input{1,4}(3),...
                         'ARENA_R',processed_user_input{1,4}(4),...
                         'PLATFORM_X',processed_user_input{1,4}(5),...
                         'PLATFORM_Y',processed_user_input{1,4}(6),...
                         'PLATFORM_R',processed_user_input{1,4}(7),...
                         'FLIP_X',processed_user_input{1,4}(8),...
                         'FLIP_Y',processed_user_input{1,4}(9)};
                  
            % Output directory
            inst.OUTPUT_DIR = processed_user_input{1,1}{2};

            % Load trajectories
            trajectories_path = processed_user_input{1,1}{1};
            [trajectories,terminate] = load_data(inst,trajectories_path,varargin{:});
            % If no trajectories were found, return
            if terminate == 1
                fprintf('\nNo animal trajectories found in the specified path: %s\n',processed_user_input{1,1}{1,2});
                return;
            else
                inst.TRAJECTORIES = trajectories;
            end    
            
            % Update centre and platform location
            new_plat_x = processed_user_input{1,4}{1,5} - processed_user_input{1,4}{1,2};
            new_plat_y = processed_user_input{1,4}{1,6} - processed_user_input{1,4}{1,3};
            if processed_user_input{1,4}{1,8}
                new_plat_x = -new_plat_x;
            end
            if processed_user_input{1,4}{1,9}
                new_plat_y = -new_plat_y;
            end    
            inst.COMMON_PROPERTIES = {'TRIAL_TIMEOUT ',processed_user_input{1,4}(1),...
             'CENTRE_X',{0},...
             'CENTRE_Y',{0},...
             'ARENA_R',processed_user_input{1,4}(4),...
             'PLATFORM_X',{new_plat_x},...
             'PLATFORM_Y',{new_plat_y},...
             'PLATFORM_R',processed_user_input{1,4}(7),...
             'FLIP_X',processed_user_input{1,4}(8),...
             'FLIP_Y',processed_user_input{1,4}(9)};
            
            % Fix trials and days numbering
            [inst, error] = fix_data(inst);
            if length(error) > 0
                % If all animals were excluded, return
                if isequal(error{1,1},'all');
                    disp('All animals were excluded, please check your Experiment Settings')
                    return
                end    
                % Else, display the exluded ids and continue
                disp('Some animals were excluded because they participated in less or more trials than the ones defined');
                fprintf('Excluded IDs: ')
                for i = 1:length(error{1,1})
                    fprintf('%d ',error{1,1}{1,i});
                end    
            end
                      
            % Segmentation
            segment_length = processed_user_input{1,5}{1};
            segment_overlap = processed_user_input{1,5}{2};
            inst.SEGMENTATION_PROPERTIES = [segment_length,segment_overlap];
            [inst.SEGMENTS, inst.PARTITION, inst.CUM_PARTITIONS] = inst.TRAJECTORIES.partition(2, 'trajectory_segmentation_constant_len', segment_length, segment_overlap);
            
            % Compute Features
            inst.FEATURES_VALUES_TRAJECTORIES = compute_features(inst.TRAJECTORIES.items, features_list, inst.COMMON_PROPERTIES);
            inst.FEATURES_VALUES_SEGMENTS = compute_features(inst.SEGMENTS.items, features_list, inst.COMMON_PROPERTIES);   
        end
    end    
end