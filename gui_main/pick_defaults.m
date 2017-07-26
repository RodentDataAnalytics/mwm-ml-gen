function [segmentations,labels,classifications] = pick_defaults(ppath)
%PICK_DEFAULTS 
    
    segmentations = {};
    %labels = {'<no labels>'};
    labels = {};
    classifications = {};
    ppath = char_project_path(ppath);
    
    files = dir(fullfile(ppath,'segmentation','*.mat'));
    for i = 1:length(files)
        segmentations = [segmentations, files(i).name];
    end
    if isempty(segmentations)
        segmentations = {''};
    end
    files = dir(fullfile(ppath,'labels','*.mat'));
    for i = 1:length(files)
        labels = [labels, files(i).name];
    end    
    if isempty(labels)
        labels = {''};
    end
    files = dir(fullfile(ppath,'Mclassification'));
    for i = 3:length(files)
        classifications = [classifications, files(i).name];
    end    
    files2 = dir(fullfile(ppath,'classification'));
    for i = 3:length(files2)
        classifications = [classifications, files2(i).name];
    end        
    if isempty(classifications) %|| length(files) == 2 
        classifications = {''};
    end
end

