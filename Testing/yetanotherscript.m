project_path = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1';

ERROR_THRESHOLD = 6;
ERROR_TRUE_THRESHOLD = 20;

WAITBAR = 0;
DISPLAY = 0;
groups = [1,2];
threshold = 0;

load(fullfile(project_path,'settings','new_properties.mat'));
load(fullfile(project_path,'settings','animal_groups.mat'));
load(fullfile(project_path,'settings','my_trajectories.mat'));
load(fullfile(project_path,'settings','my_trajectories_features.mat'));

% Animal Trajectories Map
[~, animals_trajectories_map] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman',1);
% STRATEGIES - TRANSITIONS
b_pressed = {'Strategies','Transitions'}; 

segmentations = dir(fullfile(project_path,'segmentation','*.mat'));

labels = dir(fullfile(project_path,'labels'));
idx = [labels(:).isdir];
labels = {labels(idx).name}';
labels(ismember(labels,{'.','..'})) = [];

classifications = dir(fullfile(project_path,'classification'));
idx = [classifications(:).isdir];
classifications = {classifications(idx).name}';
classifications(ismember(classifications,{'.','..'})) = [];
% 
% for i = 1:length(segmentations)
%     load(fullfile(project_path,'segmentation',segmentations(i).name));
%     
%     [~,segs,seg_length,seg_overlap] = split_segmentation_name(segmentations(i).name);
%     %find the correct labels folder
%     for j = 1:length(labels)
%         [labs,len,ovl,~,~] = split_labels_name(labels{j});
%         if str2double(seg_length) == str2double(len) && str2double(seg_overlap) == str2double(ovl)
%             idx = j;
%             break;
%         end
%         if j == length(labels)
%             errordlg('Labels folder not found.','Error');
%             i
%             return;
%         end
%     end
%     %load the data from the cross_validation.csv file
%     fn = fullfile(project_path,'labels',labels{idx},'labels','cross_validation.csv');
%     data = read_cv_file(fn);
%     data = data(:,[1,2,5]);
%     %find the correct classification folder
%     for j = 1:length(classifications)
%         [~,labels,segments,~] = split_classifier_name(classifications{j});
%         if str2double(labs) == str2double(labels) && str2double(segs) == str2double(segments)
%             idx = j;
%             break;
%         end
%         if j == length(labels)
%             errordlg('Classification folder not found.','Error');
%             i
%             return;            
%         end        
%     end    
%     
%     classifiers = dir(fullfile(project_path,'classification',classifications{idx},'*.mat'));
%     
%     %% Tiago CV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     cvErr = find(data(:,2) < ERROR_THRESHOLD);
%     cvErr = data(cvErr,1);
%     class = {};
%     z = 1;
%     tmp_idx = [];
%     for k = 1:length(classifiers)
%         [~,~,~,nc] = split_classifier_name(classifiers(k).name);
%         nc = str2double(nc);
%         tmp = find(cvErr == nc);
%         if isempty(tmp)
%             continue;
%         elseif length(tmp) > 1
%             errordlg('Error detecting the classifier.','Error');
%             i
%             return;                
%         else
%             load(fullfile(project_path,'classification',classifications{idx},classifiers(k).name));
%             class{z} = classification_configs;
%             z = z+1;
%             tmp_idx = [tmp_idx,k];
%         end
%     end
%     class_path = classifiers(tmp_idx);
% 
%     %% RESULTS CLASSIFIERS
%     % Check the classification
%     %[error,name,classifications] = check_classification(project_path,segmentation_configs,folders(f).name, 'WAITBAR',0);
%     %classifications = class
%     name = classifications{idx};     
%     % Generate the results
%     for b = 1:length(b_pressed)
%         error = generate_results(project_path, name, segmentation_configs, class, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth', 'FIGURES', 0);
%         if error
%             errordlg('Cannot create results for strategies, transitions and probabilities','Error');
%             return
%         end
%         error = generate_results(project_path, name, segmentation_configs, class, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2, 'FIGURES', 0);
%         if error
%             errordlg('Cannot create results for strategies, transitions and probabilities','Error');
%             return
%         end        
%     end     
%     % Statistics (after)
%     [error,~,~] = class_statistics(project_path, name, 'SEGMENTATION', segmentation_configs, 'CLASSIFIERS', class_path);
%     if error
%         errordlg('Error: statistics generation','Error');
%         i
%         return;        
%     end   
%     % Statistics (before)
%     [error,~,~] = class_statistics(project_path, name, 'CLASSIFIERS', class_path);
%     if error
%         errordlg('Error: statistics generation','Error');
%         i
%         return;
%     end           
%     %% RESULTS ENSEMBLE 1
%     sample = length(class);
%     iterations = 1;
%     clusters = cellfun( @(t) t.DEFAULT_NUMBER_OF_CLUSTERS, class)';
%     name = classifications{idx};  
%     [error,Mclass_folder] = execute_Mclassification(project_path, classifications{idx}, sample, iterations, threshold, 'CLUSTERS',clusters);
%     if error
%         errordlg('Error: 1 Ensemble','Error');
%         i
%         return;
%     end
%     [~,name] = fileparts(Mclass_folder);
%     [error,name,classifications] = check_classification(project_path,segmentation_configs, name, 'WAITBAR',0);
%     if error
%         errordlg('Classification check failed','Error');
%         return
%     end        
%     % Generate the results
%     for b = 1:length(b_pressed)
%         error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth', 'FIGURES', 0);
%         if error
%             errordlg('Cannot create results for strategies, transitions and probabilities','Error');
%             return
%         end
%         error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2, 'FIGURES', 0);
%         if error
%             errordlg('Cannot create results for strategies, transitions and probabilities','Error');
%             return
%         end        
%     end     
%     % Statistics (after)
%     [error,~,~] = class_statistics(project_path, name, 'SEGMENTATION', segmentation_configs);
%     if error
%         errordlg('Error: statistics generation','Error');
%         i
%         return
%     end   
%     % Statistics (before)
%     [error,~,~] = class_statistics(project_path, name);
%     if error
%         errordlg('Error: statistics generation','Error');
%         i
%         return        
%     end     
%     %% RESULTS ENSEMBLES 21
%     sample = 11;
%     iterations = 21;
%     clusters = cellfun( @(t) t.DEFAULT_NUMBER_OF_CLUSTERS, class)';
%     name = classifications{idx};  
%     [error,Mclass_folder] = execute_Mclassification(project_path, classifications{idx}, sample, iterations, threshold, 'CLUSTERS',clusters);
%     if error
%         errordlg('Error: 21 Ensembles','Error');
%         i
%         return;
%     end
%     [~,name] = fileparts(Mclass_folder);
%     [error,name,classifications] = check_classification(project_path,segmentation_configs, name, 'WAITBAR',0);
%     if error
%         errordlg('Classification check failed','Error');
%         return
%     end        
%     % Generate the results
%     for b = 1:length(b_pressed)
%         error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth', 'FIGURES', 0);
%         if error
%             errordlg('Cannot create results for strategies, transitions and probabilities','Error');
%             return
%         end
%         error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2, 'FIGURES', 0);
%         if error
%             errordlg('Cannot create results for strategies, transitions and probabilities','Error');
%             return
%         end        
%     end     
%     % Statistics (after)
%     [error,~,~] = class_statistics(project_path, name, 'SEGMENTATION', segmentation_configs);
%     if error
%         errordlg('Error: statistics generation','Error');
%         i
%         return
%     end   
%     % Statistics (before)
%     [error,~,~] = class_statistics(project_path, name);
%     if error
%         errordlg('Error: statistics generation','Error');
%         i
%         return        
%     end    
% end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
for i = 3:length(segmentations)
    load(fullfile(project_path,'segmentation',segmentations(i).name));
    
    [~,segs,seg_length,seg_overlap] = split_segmentation_name(segmentations(i).name);
    %find the correct labels folder
    for j = 1:length(labels)
        [labs,len,ovl,~,~] = split_labels_name(labels{j});
        if str2double(seg_length) == str2double(len) && str2double(seg_overlap) == str2double(ovl)
            idx = j;
            break;
        end
        if j == length(labels)
            errordlg('Labels folder not found.','Error');
            i
            return;
        end
    end
    %load the data from the cross_validation.csv file
    fn = fullfile(project_path,'labels',labels{idx},'labels','cross_validation.csv');
    data = read_cv_file(fn);
    data = data(:,[1,2,5]);
    %find the correct classification folder
    for j = 1:length(classifications)
        [~,labels_,segments,~] = split_classifier_name(classifications{j});
        if str2double(labs) == str2double(labels_) && str2double(segs) == str2double(segments)
            idx = j;
            break;
        end
        if j == length(classifications)
            errordlg('Classification folder not found.','Error');
            i
            return;            
        end        
    end    
    
    classifiers = dir(fullfile(project_path,'classification',classifications{idx},'*.mat'));
    
    %% True CV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cvErr = find(data(:,3) < ERROR_TRUE_THRESHOLD);
    cvErr = data(cvErr,1);
    class = {};
    z=1;
    tmp_idx = [];
    for k = 1:length(classifiers)
        [~,~,~,nc] = split_classifier_name(classifiers(k).name);
        nc = str2double(nc);
        tmp = find(cvErr == nc);
        if isempty(tmp)
            continue;
        elseif length(tmp) > 1
            errordlg('Error detecting the classifier.','Error');
            i
            return;                
        else
            load(fullfile(project_path,'classification',classifications{idx},classifiers(k).name));
            class{z} = classification_configs;
            z = z+1;
            tmp_idx = [tmp_idx,k];
        end
    end
    class_path = classifiers(tmp_idx);    
    
    %% RESULTS CLASSIFIERS
    % Check the classification
    %[error,name,classifications] = check_classification(project_path,segmentation_configs,folders(f).name, 'WAITBAR',0);
    %classifications = class
    name = classifications{idx};     
    % Generate the results
    for b = 1:length(b_pressed)
        error = generate_results(project_path, name, segmentation_configs, class, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth', 'FIGURES', 0);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end
        error = generate_results(project_path, name, segmentation_configs, class, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2, 'FIGURES', 0);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end        
    end     
    % Statistics (after)
    [error,~,~] = class_statistics(project_path, name, 'SEGMENTATION', segmentation_configs, 'CLASSIFIERS', class_path);
    if error
        errordlg('Error: statistics generation','Error');
        i
        return;        
    end   
    % Statistics (before)
    [error,~,~] = class_statistics(project_path, name, 'CLASSIFIERS', class_path);
    if error
        errordlg('Error: statistics generation','Error');
        i
        return;
    end           
    %% RESULTS ENSEMBLE 1
    sample = length(class);
    iterations = 1;
    clusters = cellfun( @(t) t.DEFAULT_NUMBER_OF_CLUSTERS, class)';
    name = classifications{idx};  
    [error,Mclass_folder] = execute_Mclassification(project_path, classifications(idx), sample, iterations, threshold, 'CLUSTERS',clusters);
    if error
        errordlg('Error: 1 Ensemble','Error');
        i
        return;
    end
    [~,name] = fileparts(Mclass_folder);
    [error,name,classifications_] = check_classification(project_path,segmentation_configs, name, 'WAITBAR',0);
    if error
        errordlg('Classification check failed','Error');
        return
    end        
    % Generate the results
    for b = 1:length(b_pressed)
        error = generate_results(project_path, name, segmentation_configs, classifications_, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth', 'FIGURES', 0);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end
        error = generate_results(project_path, name, segmentation_configs, classifications_, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2, 'FIGURES', 0);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end        
    end     
    % Statistics (after)
    [error,~,~] = class_statistics(project_path, name, 'SEGMENTATION', segmentation_configs);
    if error
        errordlg('Error: statistics generation','Error');
        i
        return
    end   
    % Statistics (before)
    [error,~,~] = class_statistics(project_path, name);
    if error
        errordlg('Error: statistics generation','Error');
        i
        return        
    end     
    %% RESULTS ENSEMBLES 21
    sample = 11;
    iterations = 21;
    clusters = cellfun( @(t) t.DEFAULT_NUMBER_OF_CLUSTERS, class)';
    name = classifications{idx};  
    [error,Mclass_folder] = execute_Mclassification(project_path, classifications(idx), sample, iterations, threshold, 'CLUSTERS',clusters);
    if error
        errordlg('Error: 21 Ensembles','Error');
        i
        return;
    end
    [~,name] = fileparts(Mclass_folder);
    [error,name,classifications_] = check_classification(project_path,segmentation_configs, name, 'WAITBAR',0);
    if error
        errordlg('Classification check failed','Error');
        return
    end        
    % Generate the results
    for b = 1:length(b_pressed)
        error = generate_results(project_path, name, segmentation_configs, classifications_, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 3, 'EXTRA_NAME', '_smooth', 'FIGURES', 0);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end
        error = generate_results(project_path, name, segmentation_configs, classifications_, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0, 'DISTRIBUTION', 2, 'FIGURES', 0);
        if error
            errordlg('Cannot create results for strategies, transitions and probabilities','Error');
            return
        end        
    end     
    % Statistics (after)
    [error,~,~] = class_statistics(project_path, name, 'SEGMENTATION', segmentation_configs);
    if error
        errordlg('Error: statistics generation','Error');
        i
        return
    end   
    % Statistics (before)
    [error,~,~] = class_statistics(project_path, name);
    if error
        errordlg('Error: statistics generation','Error');
        i
        return        
    end   
    return
end