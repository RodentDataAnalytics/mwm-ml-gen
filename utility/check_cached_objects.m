function path = check_cached_objects( obj, choice )
%CHECK_CACHED_OBJECTS finds if the new object exists in the cache (output)
%folder. If not it saves it.

    path = obj.OUTPUT_DIR;
    files = dir(fullfile(path,'*.mat'));
    flag = 0;
    
    % check if we have this object
    for i=1:length(files)
        load(strcat(path,'/',files(i).name));
        switch choice   
        case 1 % config_segments file
            if exist('segmentation_configs','var') == 1
                if isequal(segmentation_configs,obj)
                    flag = 1;
                    path = strcat(path,'/',files(i).name);
                    break;
                end
            end    
        case 2 % config_classification file
            if exist('classification_configs','var') == 1
                if isequal(classification_configs,obj)
                    flag = 1;
                    path = strcat(path,'/',files(i).name);
                    break;
                end
            end    
        end
    end
    
    % if this object is unexisted in cache folder save it there
    if flag == 0
        switch choice   
        case 1 % config_segments file
            time = fix(clock);
            formatOut = 'yyyy-mm-dd-HH-MM';
            time = datestr((time),formatOut);
            segmentation_configs = obj;
            save(strcat(path,'/','segmentation_configs_',time),'segmentation_configs');
            path = strcat(path,'/','segmentation_configs_',time);
        case 2 % config_classification file
            time = fix(clock);
            formatOut = 'yyyy-mm-dd-HH-MM';
            time = datestr((time),formatOut);
            classification_configs = obj;
            save(strcat(path,'/','classification_configs_',time),'classification_configs');
            path = strcat(path,'/','segmentation_configs_',time);
        end
    end 
end

