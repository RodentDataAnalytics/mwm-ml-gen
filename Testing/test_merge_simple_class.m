project_folder = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data';
project_folder = 'D:\Avgoustinos\Documents\MWMGEN\Artur_exp1_sameplat';
stepi = 10;

classifs = dir(fullfile(project_folder,'classification'));
segmentations = dir(fullfile(project_folder,'segmentation'));

for i = 8:8%length(classifs)
    
    % Get classification
    tmp = strsplit(classifs(i).name,'_');
    if length(tmp) < 5
        continue;
    end
    seg_labels = tmp{2};
    seg_number = tmp{3};
    seg_length = tmp{4};
    seg_overlap = tmp{5};
    
    % Get segmentation
    full_seg_name = strcat('segmentation_configs_',seg_number,'_',seg_length,'_',seg_overlap,'.mat');
    try
        load(fullfile(project_folder,'segmentation',full_seg_name));
    catch
        disp(strcat(full_seg_name,' does not exist'));
        continue;
    end
    
    % Get class files
    class_files = dir(fullfile(project_folder,'classification',classifs(i).name,'*.mat'));
    class_files = {class_files.name};
    [num, idx] = sort_classifiers(class_files);
    class_files = class_files(:,idx);
    n = length(class_files);
    
    % Make output folder
    parts = fix(n/stepi);
    mclass = strcat('class_',seg_labels,'_',seg_number,'_',seg_length,'_',seg_overlap,'_',num2str(stepi),'_',num2str(parts),'_mr0');
    output_folder = fullfile(project_folder,'Mclassification',mclass);
    if exist(output_folder,'dir')
        tmp = fopen('all'); %close all opened files
        for t = 1:length(tmp)
            fclose(tmp(t));
        end
        rmdir(output_folder, 's') %delete the directory
    end
    mkdir(output_folder);
    
    %% Perform majority voting
    str_ = strcat('Iteration:','1','/',num2str(parts));
    h = waitbar(0,str_,'Name','Merging');
    classifications = cell(1,stepi);
    starti = 1;
    endi = stepi;
    for iter = 1:parts
        str_ = strcat('Iteration:',num2str(iter),'/',num2str(parts));
        waitbar(iter/parts,h,str_)
        %load the class files
        clear classification_configs
        k = 1;
        for s = starti:endi
            load(fullfile(project_folder,'classification',classifs(i).name,class_files{s}));
            classifications{k} = classification_configs;
            clear classification_configs
            k = k+1;
        end
        %execute majority voting
        [classifications, ~] = majority_rule(output_folder, classifications, 0);
        %save
        classification_configs = classifications{end};
        str = sprintf('merged_%d.mat',iter);
        save(fullfile(output_folder,str),'classification_configs'); 
        starti = endi + 1;
        endi = endi + stepi;
        classifications = cell(1,stepi);
    end
    % Create a CSV-file for the undecided segments
    find_similar_unlabelled(segmentation_configs,output_folder);
    delete(h);
end

    