function error = execute_classification(project_path,seg_name,lab_name,num_clusters, varargin)
%EXECUTE_CLASSIFICATION 

    error = 1;
    unsupervised = 0;
    project_path = char_project_path(project_path);

    %% Load segmentation_config and labels
    segs = fullfile(project_path,'segmentation',seg_name);
    try
        load(segs);
    catch
        error_messages(3);
        return
    end

    if isequal(lab_name,'<no labels>')
        ALL_TAGS = tags_list;
        CLASSIFICATION_TAGS = ALL_TAGS(1,2:end);
        LABELLING_MAP = num2cell( (-1*ones(1,size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1))) );
        unsupervised = 1;
    else
        labels = fullfile(project_path,'labels',lab_name);
        try
            load(labels)
        catch
            error_messages(4);
            return
        end        
    end

     %% Parse the names
    [segs,len,ovl,ppath] = get_segmentation_name(segs);
    if isequal(lab_name,'<no labels>')
        labs = '0';
        note = '';
    else
        [labs,lenl,ovll,note,~] = split_labels_name(labels);
        if ~isequal(len,lenl) || ~isequal(ovl,ovll)
            error_messages(5);
            return
        end
    end

    %% Form tha names and make the dirs
    % project path, labels used, number of segments, segments length,
    % segments ovelap and labels note (if applicant)
    [class_folder,error] = build_classification_folder(ppath,'class',labs,segs,len,ovl,note);
    if error == 1
        error_messages(6); 
        return       
    elseif error == 2
        return
    end   

    %Nlabels = Nsegs
    if num_clusters(1) == -1;
        num_clusters = 0;
    end   
    
    %% Generate the classifiers
    if unsupervised
        error = generate_classifiers(class_folder, num_clusters, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS,'UNSUPERVISED',1 , varargin{:});
    else
        error = generate_classifiers(class_folder, num_clusters, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS, varargin{:});
    end
    
    if error
        return;
    else
        error = 0;
    end
end

