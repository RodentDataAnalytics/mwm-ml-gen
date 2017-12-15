function [error, count, percentage_per_classifier] = class_statistics(ppath, class_name, varargin)
%CLASS_STATISTICS computes statistics for the mclassification

    SEGMENTATION = 0;
    flag = 0;
    files = {};
    WAITBAR = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'SEGMENTATION')
            SEGMENTATION = 1;
            segmentation_configs = varargin{i+1};
        elseif isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        elseif isequal(varargin{i},'CLASSIFIERS')
            files = varargin{i+1};    
            flag = i+1;
        end
    end

    if WAITBAR
        h = waitbar(0,'Computing statistics...');
    end
    error = 1;
    
    if isempty(files)
        %Classifiers or Ensembles?
        tmp = strfind(class_name,'_');
        if length(tmp) == 4
            CLASSIFICATION = 1;
        else
            CLASSIFICATION = 0;
        end

        ppath = char_project_path(ppath);
        mcpath = fullfile(ppath,'Mclassification',class_name);
        if CLASSIFICATION
            mcpath = fullfile(ppath,'classification',class_name);
        end
        files = dir(fullfile(mcpath,'*.mat'));
        %sort by classifier number
        files = extractfield(files,'name')';
        [~,idx] = sort_classifiers(files);
        files = files(idx);

        % Take the tags
        load(fullfile(mcpath,files{1}))
        strats = classification_configs.ALL_TAGS;
        clear classification_configs
    else
        %sort by classifier number
        files = extractfield(files,'name')';
        [~,idx] = sort_classifiers(files);
        files = files(idx);
        CLASSIFICATION = 1;
        mcpath = fullfile(ppath,'classification',class_name);
        load(fullfile(mcpath,files{1}))
        strats = classification_configs.ALL_TAGS;        
    end
    
    % Create the folder
    if SEGMENTATION
        rpath = fullfile(ppath,'results',strcat('statistics-',class_name,'_smooth'));
    else
        rpath = fullfile(ppath,'results',strcat('statistics-',class_name));
    end
    try
        if exist(rpath,'dir')
            rmdir(rpath,'s');
        end
        mkdir(rpath);
    catch
        errordlg('Cannot create output folder','Error: Statistics')
        if WAITBAR
            delete(h);
        end
        return
    end
    
    % Calculate how many segs / strategy
    count = zeros(length(files),length(strats));
    for i = 1:length(files)
        load(fullfile(mcpath,files{i}));
        if SEGMENTATION %after smoothing
            [~,~,~,strat_distr] = distr_strategies_smoothing(segmentation_configs, classification_configs,varargin{:});
            class_map = strat_distr;
        else %pre-smoothing
            class_map = classification_configs.CLASSIFICATION.class_map;
        end
        for j = 1:length(strats)
            count(i,j) = length(find(class_map==strats{j}{3}));
        end
        % Histogram
        str = strsplit(files{i},'.mat');
        create_classification_histogram(class_map,strats,rpath,strcat(str{1},'_hist'));
        if WAITBAR
            waitbar(i/length(files));
        end
    end
    average = mean(count,1);
    count = [count;average];
    
    if WAITBAR
        waitbar(1,h,'Exporting results...');
    end

    % Calculate the percentages
    percentage_per_classifier = zeros(size(count,1),length(strats));
    for i = 1:size(percentage_per_classifier,1)
        for j = 1:size(percentage_per_classifier,2)
            percentage_per_classifier(i,j) = 100 * (count(i,j) / length(class_map));
        end
    end
    
    %variance
    if size(count,1) == 2
        v1 = zeros(1,size(count,2));
        v2 = zeros(1,size(count,2));
    else
        v1 = var(count(1:end-1,:));
        v2 = var(percentage_per_classifier(1:end-1,:));
    end
    %min-max
    if size(count,1) == 2
        mi1 = zeros(1,size(count,2));
        ma1 = zeros(1,size(count,2));
        mi2 = zeros(1,size(count,2));
        ma2 = zeros(1,size(count,2));
    else    
        mi1 = min(count(1:end-1,:));
        ma1 = max(count(1:end-1,:));
        mi2 = min(percentage_per_classifier(1:end-1,:));
        ma2 = max(percentage_per_classifier(1:end-1,:));
    end
    
    count = [count;v1;mi1;ma1];
    percentage_per_classifier = [percentage_per_classifier;v2;mi2;ma2];
    
    %% Export
    count = count'; % cols = classifiers + average, rows = strategies
    percentage_per_classifier = percentage_per_classifier';
    
    % Create the tables
    cols = cell(1,length(files)+1);
    for i = 1:length(files)
        if CLASSIFICATION
            tmp = strsplit(files{i},{'_','.mat'});
            cols{i} = strcat('class_',tmp{5});
        else
            tmp = strsplit(files{i},{'_','.mat'});
            cols{i} = strcat('ensemble_',tmp{2});
        end
    end
    cols{end} = 'average';
    cols{end+1} = 'variance';
    cols{end+1} = 'min';
    cols{end+1} = 'max';
    rows = cell(1,length(strats)+1);
    rows{1} = 'stats';
    for i = 1:length(strats)
        rows{i+1} = strats{i}{2};
    end 
    count_ = num2cell(round(count));
    count_ = [cols;count_];
    count_ = [rows',count_];
    count_ = cell2table(count_);
    percentage_per_classifier_ = num2cell(percentage_per_classifier);
    percentage_per_classifier_ = [cols;percentage_per_classifier_];
    percentage_per_classifier_ = [rows',percentage_per_classifier_];
    percentage_per_classifier_ = cell2table(percentage_per_classifier_);
    % Export the tables
    writetable(count_,fullfile(rpath,'statistics_numeric.csv'),'WriteVariableNames',0);
    writetable(percentage_per_classifier_,fullfile(rpath,'statistics_percentage.csv'),'WriteVariableNames',0);
    if WAITBAR
        delete(h);
    end
 
    % Also create the agreement matrix
    if length(cols)-4 > 1 % only if we have more than one classifiers
        if SEGMENTATION
            if flag
                results_classification_agreement(rpath,'FOLDER',mcpath,'CLASSIFICATION',CLASSIFICATION,'SEGMENTATION',segmentation_configs, 'CLASSIFIERS',varargin{flag}, 'WAITFAR',WAITBAR);
            else
                results_classification_agreement(rpath,'FOLDER',mcpath,'CLASSIFICATION',CLASSIFICATION,'SEGMENTATION',segmentation_configs, 'WAITFAR',WAITBAR);
            end
        else
            if flag
                results_classification_agreement(rpath,'FOLDER',mcpath,'CLASSIFICATION',CLASSIFICATION, 'CLASSIFIERS',varargin{flag}, 'WAITFAR',WAITBAR);
            else
                results_classification_agreement(rpath,'FOLDER',mcpath,'CLASSIFICATION',CLASSIFICATION, 'WAITFAR',WAITBAR);
            end
        end
    end
    
    error = 0;
end

