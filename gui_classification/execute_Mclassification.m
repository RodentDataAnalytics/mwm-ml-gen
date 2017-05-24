function [error,Mclass_folder] = execute_Mclassification(project_path, classification, sample, iterations, threshold, varargin)
%EXECUTE_MCLASSIFICATION merges the classification results of different
%classifiers

    project_path = char_project_path(project_path);
    class_path = char_project_path(fullfile(project_path,'classification',classification{1}));
    
    temp = strsplit(classification{1},'_');
    segs = temp{3};
    len = temp{4};
    ovl = strsplit(temp{5},'-');
    ovl = ovl{1};
    %construct the full path of the segmentation object
    n_path = fullfile(project_path,'segmentation',strcat('segmentation_configs_',segs,'_',len,'_',ovl,'.mat'));
    try
        load(n_path);
    catch
        error_message(12);
    end
    %check number of available classifiers
    f = dir(fullfile(class_path,'*.mat'));
    if length(f) == 0
        error_message(14);
        return;
    elseif length(f) <= sample
        iterations = 1;
        sample = length(f);
    end
    
    %% Create merged classification folder
    % folder of the classifiers, number of classifiers, number of
    % iterations, technique (majority rule with 0 threshold)
    [Mclass_folder,error] = build_Mclassification_folder(class_path, num2str(sample), num2str(iterations), strcat('mr',num2str(threshold)));
    if error
        error_messages(11);
        return        
    end        
    
    %% Merge using majority voting
    error = majority_rule_init(segmentation_configs, Mclass_folder, class_path, sample, threshold, iterations, varargin{:});
    if ~error
        error = 0;
    end
end

