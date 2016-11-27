function results_class_weights(varargin)
% Computes class weights for:
% a) Weights = ones;
% b) Weights = computed
% c) Weights = computed + hard bounded
  
    names = {'ones' 'computed' 'bounded'};
    N = length(names);

    % Get special folder 'Documents' as char
    if ismac
        doc_path = char(java.lang.System.getProperty('user.home'));
        doc_path = fullfile(doc_path,'Documents');
    else
        doc_path = char(getSpecialFolder('MyDocuments'));
    end

    % Get merged classifications
    if isempty(varargin)
        folder = uigetdir(doc_path,'Select one Merged Classification folder');
    else
        if exist(varargin{1},'dir')
            folder = varargin{1};
        else
            folder = uigetdir(doc_path,'Select one Merged Classification folder'); 
        end
    end
    if isnumeric(folder)
        return;
    end
    files = dir(fullfile(folder,'*.mat'));
    if isempty(files)
        errordlg('No merged classifiers found.','Error');
        return;
    end
    
    % Check if folder is correct
    try
        load(fullfile(folder,files(1).name));
    catch
        errordlg('Cannot load merged classifier file','Error');
        return;
    end
    if ~exist('classification_configs','var')
        errordlg('The specified folder does not contain classification_configs files','Error');
        return;
    end

    % Get project's results path
    root = fileparts(fileparts(folder));
    fresults = fullfile(root,'results');

    % Generate output folder tree
    fprintf('Generating output folder tree...\n');
    
    folder_special_results = fullfile(fresults,'special');
    if ~exist(folder_special_results,'dir')
        mkdir(fullfile(folder_special_results));
    end
    name = strsplit(folder,'\');
    name = name{end};
    tmp_path = fullfile(folder_special_results,strcat('weights-',name));
    if exist(tmp_path,'dir');
        rmdir(tmp_path,'s');
    end
    mkdir(tmp_path);
    
    % Find the correct segmentation
    fprintf('Searching segmentation...\n');
    
    error = 1;
    segs = size(classification_configs.FEATURES,1);
    segmentations = dir(fullfile(root,'segmentation','*.mat'));
    for i = 1:length(segmentations)
        load(fullfile(root,'segmentation',segmentations(i).name));
        if size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1) == segs
            error = 0;
            break;
        end
    end
    if error
        errordlg('Segmentation not found.','Error');
        return;
    end
    
    %% COMPUTE THE WEIGHTS
    fprintf('Computing the weights...\n');
    
    strat_distr_all = cell(length(files),1);
    weights_all = cell(length(files),1);
    for i = 1:length(files)
        load(fullfile(folder,files(i).name));
        tmp = cell(1,3);
        tmp_w = cell(1,3);
        % WEIGHTS = ones
        [strat_distr, ~, ~, class_w] = distr_strategies(segmentation_configs, classification_configs, 'weights', 'ones', 'norm_method', 'off', 'hard_bounds', 'off');
        tmp{1} = strat_distr;
        tmp_w{1} = class_w;
        % WEIGHTS = computed, unbounded
        [strat_distr, ~, ~, class_w] = distr_strategies(segmentation_configs, classification_configs, 'weights', 'computed', 'norm_method', 'off', 'hard_bounds', 'off');
        tmp{2} = strat_distr;
        tmp_w{2} = class_w;
        % WEIGHTS = computed, with bounds
        [strat_distr, ~, ~, class_w] = distr_strategies(segmentation_configs, classification_configs, 'weights', 'computed', 'norm_method', 'off', 'hard_bounds', 'on');
        tmp{3} = strat_distr;
        tmp_w{3} = class_w;
        % collect everything
        strat_distr_all{i} = [tmp(1),tmp(2),tmp(3)];
        weights_all{i} = [tmp_w(1),tmp_w(2),tmp_w(3)];
    end
    
    %% EXPORT THE WEIGHTS
    fprintf('Saving...\n');
    
    save(fullfile(tmp_path,'strat_distr_all.mat'),'strat_distr_all');
    save(fullfile(tmp_path,'weights_all.mat'),'weights_all');
    tags = cell(length(classification_configs.CLASSIFICATION_TAGS),1);
    for i = 1:length(tags)
        tags{i} = classification_configs.CLASSIFICATION_TAGS{i}{2};
    end
    header = cell(1,length(weights_all)+1);
    for i = 1:length(weights_all)
        header{i+1} = strcat('class',num2str(i));
    end
    
    fprintf('Exporting...\n');
    
    for n = 1:N
        table = tags;
        for i = 1:length(weights_all)
            element = num2cell(weights_all{i}{n})';
            table = [table, element];
        end
        header{1} = names{n};
        table = [header ; table];
        table = cell2table(table);
        writetable(table,fullfile(tmp_path,strcat(names{n},'.csv')),'WriteVariableNames',0);
    end
end
    
            
   
    