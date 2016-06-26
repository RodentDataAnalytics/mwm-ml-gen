function [error] = check_object_output_dir(option, varargin)
%CHECK_PATH checks if the object's OUTPUT_FOLDER exists and if not it
%asks the user to update it

%RETURNS:
% ERROR = 0: No error
% ERROR = 1: Cannot load mat file
% ERROR = 2: Wrong object was loaded


    obj_name = varargin{1};
    obj_path = varargin{2};
    error = 0;
    try
        load(strcat(obj_path,obj_name));
    catch
        error = 1;
        return
    end    
    
    switch(option)
        case 1
        %% Segmentation Object
        if exist('segmentation_configs','var') == 1
            path = segmentation_configs.OUTPUT_DIR;
            if exist(path, 'dir') ~= 7
                disp('Segmentation Configurations Object output path is unexisted. Specify a new output path');
                FN_output = uigetdir(matlabroot,'Select output folder');
                segmentation_configs.OUTPUT_DIR = FN_output;
                save(strcat(obj_path,'/',obj_name),'segmentation_configs');
            end
        else  
            error = 2;
            return
        end
        
        case 2
        %% Classification Object
        if exist('classification_configs','var') == 1
            path = classification_configs.OUTPUT_DIR;
            if exist(path, 'dir') ~= 7
                disp('Classification Configurations Object output path is unexisted. Specify a new output path');
                FN_output = uigetdir(matlabroot,'Select output folder');
                classification_configs.OUTPUT_DIR = FN_output;
                save(strcat(obj_path,'/',obj_name),'classification_configs');
            end
        else
            error = 2;
            return            
        end    
    end
end

