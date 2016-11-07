function generate_mat_from_labels(labels_path,segmentation_configs)
%GENERATE_MAT_FROM_LABELS given a labels CSV file and a segmentation_configs
%object it generates a .MAT file containing the: LABELLING_MAP, ALL_TAGS,
%CLASSIFICATION_TAGS

    segments = segmentation_configs.SEGMENTS;
    % Tag trajectories/segments if data are available
    [~, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS] = setup_tags(segments,labels_path);
    [pathstr,name,~] = fileparts(labels_path);
    save(fullfile(pathstr,strcat(name,'.mat')),'LABELLING_MAP','ALL_TAGS','CLASSIFICATION_TAGS');
end

