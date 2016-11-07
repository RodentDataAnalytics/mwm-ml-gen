function save_segmentation(segmentation_configs, project_path)
%SAVE_SEGMENTATION saves a segmentation object

    %name and save
    p1 = num2str(segmentation_configs.SEGMENTATION_PROPERTIES(1));
    p2 = num2str(segmentation_configs.SEGMENTATION_PROPERTIES(2));
    %remove the dot
    p2(regexp(p2,'[.]')) = [];
    p3 = num2str(size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1));
    name = strcat('segmentation_configs_',p3,'_',p1,'_',p2,'.mat');
    save(fullfile(project_path,'segmentation',name),'segmentation_configs');
end

