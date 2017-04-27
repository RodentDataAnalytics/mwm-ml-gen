function generate_mat_from_labels(labels_path,obj)
%GENERATE_MAT_FROM_LABELS given a labels CSV file and a segmentation_configs
%object it generates a .MAT file containing the: LABELLING_MAP, ALL_TAGS,
%CLASSIFICATION_TAGS

    if isa(obj,'config_segments')
        segments = obj.SEGMENTS;
    elseif isa(obj,'trajectories')
        segments = obj;
    end
    % Tag trajectories/segments if data are available
    [~, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS] = setup_tags(segments,labels_path);
    [pathstr,name,~] = fileparts(labels_path);
    save(fullfile(pathstr,strcat(name,'.mat')),'LABELLING_MAP','ALL_TAGS','CLASSIFICATION_TAGS');
    
    % Generate dummy segmentation object if needed
%     if isa(obj,'trajectories')
%         [error,~,~,~] = initialize_classification(handles,eventdata);
%         if error
%             errordlg('Segmentation object for full trajectories couldn''t be created.','Error');
%         end
%     end
end

