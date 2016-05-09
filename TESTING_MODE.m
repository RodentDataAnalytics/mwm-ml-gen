function TESTING_MODE(varargin)
%TESTING_MODE is used for testing purposes and to generate the paper's
%results

% config_segments(user_input,1)
% the second variable activates the "if isempty(varargin)" of load_data
% which keeps only the animal groups 1 and 2 as in the original program

% If the path{1,2} contains "mwm_peripubertal_stress" then the data used in
% the original program are used. These data are then calibrated.

% check_cached_objects(obj,#)
% If # = 1: segmentation object expected.
% If # = 2: classification object expected.

%% Default Options
% By running this code the following are set:
% Input Data: .../mwm-ml-gen/data/mwm_peripubertal_stress
% Animal Groups: Only groups 1 and 2 are selected
% Output Folder: .../mwm-ml-gen/cache/

%% User Input
if isempty(varargin) % Activated only by running as script
    prompt={'Please choose setup 1, 2 or 3 for the 	respective classifications as shown on Table 2 page 6'};
    name = 'Original results';
    defaultans = {'3'};
    options.Interpreter = 'tex';
    setup = inputdlg(prompt,name,[1 30],defaultans,options);
    setup = setup_validation(setup);
    if setup == -1
        warndlg('Input must be 1, 2 or 3.');
        return
    elseif setup == -2
        return
    end
else % Activated only by running from GUI
    setup = setup_validation(varargin);
    if setup == -1
        warndlg('Input must be 1, 2 or 3.');
        return
    end
end

%% Set paths and initialize WIKA
path = initializer;

%% Global data
folds = 10;
group_1 = 1;
group_2 = 2;
path_groups = strcat(path{1,2},'/trajectory_groups.csv');
path_data = path{1,2};
path_output = path{1,1};  

% choose configurations
switch setup
    case 3
        % Segmentation + Features
        user_input = {{path_groups,path_data,path_output},{3,str2num('4,4,4'),'Training','Control,Stress,Control/Food,Stress/Food'},{90,0,0,100,-50,10,6,5,40},{250,0.9}};
        segmentation_configs_1 = config_segments(user_input,1);
        % Save the object if it is now existed in cache
        path_seg = check_cached_objects(segmentation_configs_1,1);

        % Clustering + Classification
        path_labels = strcat(path{1,2},'/segment_labels_250_90.csv');
        user_input = {{path_labels,path_seg},75};
        classification_configs_1 = config_classification(user_input);
        % Save the object if it is now existed in cache
        check_cached_objects(classification_configs_1,2);
        
        % Results and figures
        RUN_ALL_RESULTS( segmentation_configs_1, classification_configs_1, path_labels, folds, group_1, group_2 );
        
    case 2
        % Segmentation + Features
        user_input = {{path_groups,path_data,path_output},{3,str2num('4,4,4'),'Training','Control,Stress,Control/Food,Stress/Food'},{90,0,0,100,-50,10,6,5,40},{250,0.7}};
        segmentation_configs_2 = config_segments(user_input,1);
        % Save the object if it is now existed in cache
        path_seg = check_cached_objects(segmentation_configs_2,1);
        
        % Clustering + Classification
        path_labels = strcat(path{1,2},'/segment_labels_250_70.csv');
        user_input = {{path_labels,path_seg},35};
        classification_configs_2 = config_classification(user_input);
        % Save the object if it is now existed in cache
        check_cached_objects(classification_configs_2,2);
        
        % Results and figures        
        RUN_ALL_RESULTS( segmentation_configs_2, classification_configs_2, path_labels, folds, group_1, group_2 );
          
    case 1
        % Segmentation + Features 
        user_input = {{path_groups,path_data,path_output},{3,str2num('4,4,4'),'Training','Control,Stress,Control/Food,Stress/Food'},{90,0,0,100,-50,10,6,5,40},{300,0.7}};
        segmentation_configs_3 = config_segments(user_input,1); 
        % Save the object if it is now existed in cache
        path_seg = check_cached_objects(segmentation_configs_3,1);
        
        % Clustering + Classification
        path_labels = strcat(path{1,2},'/segment_labels_300_70.csv');
        user_input = {{path_labels,path_seg},37};
        classification_configs_3 = config_classification(user_input);
        % Save the object if it is now existed in cache
        check_cached_objects(classification_configs_3,2);
        
        % Results and figures  
        RUN_ALL_RESULTS( segmentation_configs_3, classification_configs_3, path_labels, folds, group_1, group_2 );
end

