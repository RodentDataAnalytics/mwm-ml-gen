project_path = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1';

ttitle = {'Segmentation I','Segmentation II','Segmentation III','Segmentation IV'};
%300-0.7, 250-0.7, 250-0.9, 300-0.7
skip = {'989','2445','1261'};

WAITBAR = 0;
DISPLAY = 0;
groups = [1,2];

load(fullfile(project_path,'settings','new_properties.mat'));
load(fullfile(project_path,'settings','animal_groups.mat'));
load(fullfile(project_path,'settings','my_trajectories.mat'));
load(fullfile(project_path,'settings','my_trajectories_features.mat'));

%% Mclassification
folders = dir(fullfile(project_path,'Mclassification'));
segs = dir(fullfile(project_path,'segmentation','*.mat'));

for f = 3:length(folders)
    [~,labs,~,seg_length,seg_overlap,~,~,~] = split_mclassification_name(folders(f).name);
    
    %skip
    tmp = 0;
    for i = 1:length(skip)
        if isequal(labs,skip{i})
            tmp = 1;
            break;
        end
    end
    if tmp == 1
        continue;
    end
    
    for s = 1:length(segs)
        [~,~,sl,so] = split_segmentation_name(segs(s).name);
        if isequal(seg_length,sl) && isequal(seg_overlap,so)
            load(fullfile(project_path,'segmentation',segs(s).name));
            break;
        end
    end
    
    %% RESULTS
    % Animal Trajectories Map
    [~, animals_trajectories_map] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman',1);
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS
    b_pressed = {'Strategies','Transitions'};
    
    % Check the classification
    [error,name,classifications] = check_classification(project_path,segmentation_configs,folders(f).name, 'WAITBAR',0);
    if error
        errordlg('Classification check failed','Error');
        return
    end        
    % Generate the results
    for b = 1:length(b_pressed)
        error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth');
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end
        error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end        
    end     
    % Statistics (after)
    [error,~,~] = class_statistics(project_path, folders(f).name, 'SEGMENTATION', segmentation_configs);
    if error
        errordlg('Error: statistics generation','Error');
    end   
    % Statistics (before)
    [error,~,~] = class_statistics(project_path, folders(f).name);
    if error
        errordlg('Error: statistics generation','Error');
    end     
end

%% Classification
folders = dir(fullfile(project_path,'classification'));
segs = dir(fullfile(project_path,'segmentation','*.mat'));

for f = 3:length(folders)
    [~,labs,~,seg_length,seg_overlap,~,~,~] = split_mclassification_name(folders(f).name);
    
    %skip
    tmp = 0;
    for i = 1:length(skip)
        if isequal(labs,skip{i})
            tmp = 1;
            break;
        end
    end
    if tmp == 1
        continue;
    end
    
    for s = 1:length(segs)
        [~,~,sl,so] = split_segmentation_name(segs(s).name);
        if isequal(seg_length,sl) && isequal(seg_overlap,so)
            load(fullfile(project_path,'segmentation',segs(s).name));
            break;
        end
    end
    
    %% RESULTS
    % Animal Trajectories Map
    [~, animals_trajectories_map] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman',1);
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS
    b_pressed = {'Strategies','Transitions'};
    
    % Check the classification
    [error,name,classifications] = check_classification(project_path,segmentation_configs,folders(f).name, 'WAITBAR',0);
    if error
        errordlg('Classification check failed','Error');
        return
    end        
    % Generate the results
    for b = 1:length(b_pressed)
        error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth');
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end
        error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end        
    end     
    % Statistics (after)
    [error,~,~] = class_statistics(project_path, folders(f).name, 'SEGMENTATION', segmentation_configs);
    if error
        errordlg('Error: statistics generation','Error');
    end   
    % Statistics (before)
    [error,~,~] = class_statistics(project_path, folders(f).name);
    if error
        errordlg('Error: statistics generation','Error');
    end     
end