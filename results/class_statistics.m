function [error, count, percentage_per_classifier] = class_statistics(ppath, class_name)
%CLASS_STATISTICS computes statistics for the mclassification

    h = waitbar(0,'Computing statistics...');
    error = 1;
    
    ppath = char_project_path(ppath);
    mcpath = fullfile(ppath,'Mclassification',class_name);
    files = dir(fullfile(mcpath,'*.mat'));
    
    % Take the tags
    load(fullfile(mcpath,files(1).name))
    strats = classification_configs.ALL_TAGS;
    clear classification_configs
    
    % Calculate how many segs / strategy
    count = zeros(length(files),length(strats));
    for i = 1:length(files)
        load(fullfile(mcpath,files(i).name));
        class_map = classification_configs.CLASSIFICATION.class_map;
        for j = 1:length(strats)
            count(i,j) = length(find(class_map==strats{j}{3}));
        end
        waitbar(i/length(files));
    end
    average = mean(count,1);
    count = [count;average];
    
    waitbar(1,h,'Exporting results...');

    % Calculate the percentages
    percentage_per_classifier = zeros(size(count,1),length(strats));
    for i = 1:size(percentage_per_classifier,1)
        for j = 1:size(percentage_per_classifier,2)
            percentage_per_classifier(i,j) = 100 * (count(i,j) / length(class_map));
        end
    end
    
    %% Export
    count = count'; % cols = classifiers + average, rows = strategies
    percentage_per_classifier = percentage_per_classifier';
    % Create the folder
    rpath = fullfile(ppath,'results',strcat('statistics-',class_name));
    try
        if exist(rpath,'dir')
            rmdir(rpath,'s');
        end
        mkdir(rpath);
    catch
        errordlg('Cannot create output folder','Error: Statistics')
        delete(h);
        return
    end
    % Create the tables
    cols = cell(1,length(files)+1);
    for i = 1:length(files)
        cols{i} = strcat('mclass_',num2str(i));
    end
    cols{end} = 'average';
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
    delete(h);
 
    % Also create the agreement matrix
    if length(cols) > 2 % only if we have more than one classifiers
        results_classification_agreement(rpath,mcpath);
    end
    
    error = 0;

end

