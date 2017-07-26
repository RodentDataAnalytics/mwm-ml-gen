function error = default_classification(project_path,seg_name,lab_name,ret,varargin)
%DEFAULT_CLASSIFICATION 

    error = 1;
    project_path = char_project_path(project_path);

    %% Load segmentation_config and labels
    labels = fullfile(project_path,'labels',lab_name);
    try
        load(labels)
    catch
        errordlg('Cannot load labels.','Error');
        return
    end  
    segs = fullfile(project_path,'segmentation',seg_name);
    try
        load(segs)
    catch
        errordlg('Cannot load segmentation.','Error');
        return
    end
    
    %% Initialize
    handles{1} = lab_name;
    handles{2} = seg_name;
    handles{3} = 0;
    handles{4} = project_path;
    [error,ppath,seg_name,lab_name,~] = initialize_classification(handles,'TEST_NUM_CLUSTERS',0);    
    if error
        return
    end
    
    %% Create classification folder
    % project path, labels used, number of segments, segments length,
    % segments ovelap and labels note (if applicant)
    [labs,len,ovl,note,~] = split_labels_name(lab_name);
    [~,segs,~,~] = split_segmentation_name(seg_name);
    [class_folder,error] = build_classification_folder(ppath,'class',labs,segs,len,ovl,note);
    if error == 1
        errordlg('Cannot create classification folder','Error');
        return        
    elseif error == 2
        error = 0;
        return
    end
    
    % if Nlabs = Nsegs
    if isequal(labs,segs)
        generate_classifiers(class_folder, 0, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS);
        return;
    end
    
    %% Generate Classifiers
    if isempty(note)
        cvpath = fullfile(project_path,'labels',strcat('labels_',labs,'_',len,'_',ovl,'_check'),'labels','cross_validation.csv');
    else
        cvpath = fullfile(project_path,'labels',strcat('labels_',labs,'_',len,'_',ovl,'-',note,'_check'),'labels','cross_validation.csv');
    end
    if ~exist(cvpath,'file')
        error = 2;
        rmdir(class_folder, 's')
        return;
    end   
    data = read_cv_file(cvpath);
    data = data(:,[1,2,5]);
    cvErr = find(data(:,3) < ret(4));
    num_clusters = data(cvErr,1);
    if isempty(num_clusters)
        error = 0;
        rmdir(class_folder, 's');
        msgbox('No classifiers were created.','Info');
        return;        
    end
    er = generate_classifiers(class_folder, num_clusters, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS, 'SKIP_CHECK',num_clusters, varargin{:});
    if er
        errordlg('Cannot generate classifiers.','Error');
        return
    end

    %% Create merged classification folder
    % folder of the classifiers, number of classifiers, number of
    % iterations, technique (majority rule with 0 threshold)
    [Mclass_folder,error] = build_Mclassification_folder(class_folder,num2str(length(cvErr)),'1','mr0');
    if error
        errordlg('Cannot create merged classification folder.','Error');
        return        
    end   
    
    %% Merge using majority voting
    sample = length(cvErr);
    threshold = 0;
    iterations = 1;
    error = majority_rule_init(segmentation_configs, Mclass_folder, class_folder, sample, threshold, iterations, 'CLUSTERS',num_clusters);
    if ~error
        error = 0;
    else
        errordlg('Error performing majority voting.','Error');
    end    
end

