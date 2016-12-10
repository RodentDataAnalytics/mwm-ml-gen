function error = default_classification(project_path,seg_name,lab_name)
%DEFAULT_CLASSIFICATION 

    error = 1;
    project_path = char_project_path(project_path);

    %% Load segmentation_config and labels
    labels = fullfile(project_path,'labels',lab_name);
    try
        load(labels)
    catch
        errordlg('Cannot load labels','Error');
        return
    end  
    segs = fullfile(project_path,'segmentation',seg_name);
    try
        load(segs)
    catch
        errordlg('Cannot load segmentation','Error');
        return
    end
    
    %% Parse the names
    [segs,len,ovl,ppath] = get_segmentation_name(segs);
    [labs,lenl,ovll,note,~] = split_labels_name(labels);
    if ~isequal(len,lenl) || ~isequal(ovl,ovll)
        errordlg('The selected segmentation and labels do not match','Error');
        return
    end
    
    %% Create classification folder
    % project path, labels used, number of segments, segments length,
    % segments ovelap and labels note (if applicant)
    skip = 0;
    [class_folder,error] = build_classification_folder(ppath,'class',labs,segs,len,ovl,note);
    if error == 1
        errordlg('Cannot create classification folder','Error');
        return        
    elseif error == 2
        skip = 1;
    end

    %% Generate Classifiers
    if ~skip
        num_clusters = ''; %generates 30 random classifiers
        error = generate_classifiers(class_folder, num_clusters, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS);
        if error
            return
        end
    end
    
    %% Create merged classification folder
    % folder of the classifiers, number of classifiers, number of
    % iterations, technique (majority rule with 0 threshold)
    [Mclass_folder,error] = build_Mclassification_folder(class_folder,'10','10','mr0');
    if error
        errordlg('Cannot create merged classification folder','Error');
        return        
    end        
    
    %% Merge using majority voting
    sample = 10;
    threshold = 0;
    iterations = 10;
    error = majority_rule_init(segmentation_configs, Mclass_folder, {class_folder}, sample, threshold, iterations);
    if ~error
        error = 0;
    end
end

