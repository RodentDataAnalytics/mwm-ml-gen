function error = execute_Mclassification(project_path, classifications, sample, iterations, threshold)
%EXECUTE_MCLASSIFICATION

    project_path = char_project_path(project_path);
    class_paths = {};
    for i = 1:length(classifications)
        class_paths = [class_paths,fullfile(project_path,'classification',classifications{i})];
    end
    
    %if more than one classification groups are selected then we need the
    %the appropriate segmentation objects.  
    if length(classifications) > 1
        seg_objs = cell(1,length(classifications));
        for i = 1:length(classifications)
            %get segs, len, ovl of classification
            temp = strsplit(classifications{i},'_');
            segs = temp{3};
            len = temp{4};
            ovl = temp{5};
            %construct the full path of the segmentation object
            n_path = fullfile(project_path,'segmentation',strcat('segmentation_configs_',segs,'_',len,'_',ovl,'.mat'));
            %test if file exists
            try
                load(n_path);
                seg_objs{i} = segmentation_configs;
                clear segmentation_configs;
            catch
                errordlg('Cannot execute merged classification, because equivalent segmentations do not exist','Error')
                return
            end
        end
    else
        class_paths = class_paths{1};
    end

    %% Create merged classification folder
    % folder of the classifiers, number of classifiers, number of
    % iterations, technique (majority rule with 0 threshold)
    [Mclass_folder,error] = build_Mclassification_folder(class_paths, num2str(sample), num2str(iterations), strcat('mr',num2str(threshold)));
    if error
        errordlg('Cannot create merged classification folder','Error');
        return        
    end        
    
    %% Merge using majority voting
    if ~iscell(class_paths)
        class_paths = {class_paths};
    end
    if length(classifications) > 1
        error = majority_rule_init(Mclass_folder, class_paths, sample, threshold, iterations, seg_objs);
    else
        error = majority_rule_init(Mclass_folder, class_paths, sample, threshold, iterations);
    end
    if ~error
        error = 0;
    end
end

