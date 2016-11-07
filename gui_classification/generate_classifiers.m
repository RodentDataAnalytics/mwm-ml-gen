function er = generate_classifiers(cpath, num_clusters, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS)
%GENERATE_CLASSIFIERS generate a series of classifiers and places them
%inside the specified folder

%INPUTS:
% cpath: folder in which the generated classifiers will be placed
% num_clusters: empty string or string containing comma separated values 
% segmentation_configs: segmentation object (.mat file)
% The rest of the variables are containing inside the label_name.mat

%Note: LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS can be loaded by using
%the command: load(strcat(project_path,'labels/',label_name.mat));

    er = 1;
    % Check the clusters
    tags = length(CLASSIFICATION_TAGS);
    [error,numbers,removed] = check_num_of_clusters(num_clusters,tags);
    if error == 1
        %terminate
        errordlg('Wrong input for Clusters');
        return;
    end
    if error == 2
        %generate [length(tags+2)]*10 numbers and picks 'a' of those that
        %are bigger or equal to tags+2
        random_nums = randperm((tags+2)*10);
        indexes = find(random_nums >= tags+2);
        a = randperm(30); %how many numbers to pick
        numbers = random_nums(indexes(a));
    elseif error == 0
        %ask if terminate or continue
        if ~isempty(removed)
            str = strcat(num2str(length(removed)),' numbers were too small and will be excluded. Thus ',num2str(length(numbers)),' classifiers will be generated. Do you wish to continue?');
            choice = questdlg(str,'Classifiers','Yes','No','No');
            if isequal(choice,'No');
                er = 0;
                return
            end
        end    
    end   

    % Generate the classifiers
    h = waitbar(0,'Generating classifiers...');
    for i = 1:length(numbers)
        DEFAULT_NUMBER_OF_CLUSTERS = numbers(i);
        classification_configs = config_classification(segmentation_configs,DEFAULT_NUMBER_OF_CLUSTERS,LABELLING_MAP,ALL_TAGS,CLASSIFICATION_TAGS);
        %name and save
        name = generate_name_classifiers(classification_configs);
        name = strcat('classification_configs_',name,'.mat');
        save(fullfile(cpath,name),'classification_configs');
        waitbar(i/length(numbers));
    end   
    er = 0;
    close(h)
end

