function [class_1,class_2,diff] = test_similarity(pr_folder,f1,f2)
%%TEST_SIMILARITY
    
    class_1 = [];
    class_2 = [];
    similarities = [];
    diff = [];
    
    [~,~,a] = fileparts(f1);
    [~,~,b] = fileparts(f2);
    if isdir(f1) && isdir(f2)
        flag = 'folders';
    elseif isequal(a,'.mat') && isequal(b,'.mat')
        flag = 'files';
    else
        return
    end

    switch flag
        case 'folders'
            h = waitbar(0,'Initializing...');
            segmentations = {};
            k = 1;
            files1 = dir(fullfile(f1,'*.mat'));
            if isempty(files1)
                errordlg('No classification file found','Error');
                return
            end
            load(fullfile(f1,files1(1).name));
            if ~exist('classification_configs','var')
                errordlg('Wrong specified folder','Error');
                return
            end
            s1 = length(classification_configs.CLASSIFICATION.class_map);
            clear classification_configs
            files2 = dir(fullfile(f2,'*.mat'));
            load(fullfile(f2,files2(1).name));
            if ~exist('classification_configs','var')
                errordlg('Wrong specified folder','Error');
                return
            end
            s2 = length(classification_configs.CLASSIFICATION.class_map);
            %find the segmentations
            files = dir(fullfile(pr_folder,'segmentation','*.mat'));
            for i = 1:length(files)
                segs = strsplit(files(i).name,'_');
                if str2double(segs{3}) == s1 || str2double(segs{3}) == s2
                    clear segmentation_configs
                    load(fullfile(pr_folder,'segmentation',files(i).name))
                    segmentations{k} = segmentation_configs;
                    k = k+1;
                end
                waitbar(i/length(files));
            end
            %iterate as many times as the files available
            a = min(length(files1),length(files2));
            classifications = cell(1,2);
            similarities = [];
            strats = [];
            waitbar(0,h,'Iterate','Name','Collect Classifications');
            for i = 1:a
                str = strcat('Classification:',sprintf('%d',i),'/',sprintf('%d',a));
                waitbar(i/a,h,str);
                load(fullfile(f1,files1(i).name));
                classifications{1} = classification_configs;
                clear classification_configs
                load(fullfile(f2,files2(i).name));
                classifications{2} = classification_configs;  
                clear classification_configs
                [similarity,strat] = check_similarity(segmentations,classifications);
                if isempty(similarity)
                    close(h);
                    return
                end
                similarities = [similarity,similarities];
                strats = [strats;strat(2:3,:)];
            end    
            close(h);
        case 'files'
            h = waitbar(0,'Computing...');
            segmentations = {};
            classifications = {};
            k = 1;
            load(f1);
            if ~exist('classification_configs','var')
                errordlg('Wrong file input','Error');
                return
            end
            s1 = length(classification_configs.CLASSIFICATION.class_map);
            classifications{1} = classification_configs;
            clear classification_configs
            load(f2);
            if ~exist('classification_configs','var')
                errordlg('Wrong file input','Error');
                return
            end
            s2 = length(classification_configs.CLASSIFICATION.class_map);
            classifications{2} = classification_configs;
            %find the segmentations
            files = dir(fullfile(pr_folder,'segmentation','*.mat'));
            for i = 1:length(files)
                segs = strsplit(files(i).name,'_');
                if str2double(segs{3}) == s1 || str2double(segs{3}) == s2
                    clear segmentation_configs
                    load(fullfile(pr_folder,'segmentation',files(i).name))
                    segmentations{k} = segmentation_configs;
                    k = k+1;
                end
                waitbar(i/length(files));
            end
            similarities = [];
            strats = [];
            [similarity,strat] = check_similarity(segmentations,classifications);
            if isempty(similarity)
                close(h);
                return
            end
            similarities = [similarity,similarities];
            strats = [strats;strat(2:3,:)];
            close(h);
    end
    %count strategies and compute the percentage of similarity
    class_1 = zeros(1,size(strats,2));
    class_2 = zeros(1,size(strats,2));
    for i = 1:size(strats,1)
        if mod(i,2) == 1 %odd
            class_1 = class_1 + strats(i,:);
        else
            class_2 = class_2 + strats(i,:);
        end
    end
    class_1 = round(class_1./length(similarities));
    class_2 = round(class_2./length(similarities));
    diff = abs(class_1 - class_2);
end
    