function er = generate_classifiers(cpath, numbers, segmentation_configs, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS, varargin)
%GENERATE_CLASSIFIERS generate a series of classifiers and places them
%inside the specified folder

%INPUTS:
% cpath: folder in which the generated classifiers will be placed
% num_clusters: empty string or string containing comma separated values 
% segmentation_configs: segmentation object (.mat file)
% The rest of the variables are containing inside the label_name.mat

%Note: LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS can be loaded by using
%the command: load(strcat(project_path,'labels/',label_name.mat));

    WAITBAR = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};         
        end
    end

    % Generate the classifiers
    if WAITBAR
        h = waitbar(0,'Generating classifiers...');
    end
    fn = fullfile(cpath,'errorlog.txt');
    fileID = fopen(fn,'wt');
    for i = 1:length(numbers)
        DEFAULT_NUMBER_OF_CLUSTERS = numbers(i);
        classification_configs = config_classification(segmentation_configs,DEFAULT_NUMBER_OF_CLUSTERS,LABELLING_MAP,ALL_TAGS,CLASSIFICATION_TAGS,varargin{:});
        %name and save
        name = generate_name_classifiers(classification_configs);
        name = strcat('classification_configs_',name,'.mat');
        save(fullfile(cpath,name),'classification_configs');
        if classification_configs.flag == 0
            fprintf(fileID,'%s\n',num2str(numbers(i)));
        end
        if WAITBAR
            waitbar(i/length(numbers));
        end
    end   
    er = 0;
    if WAITBAR
        delete(h)
    end
end

