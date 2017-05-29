function [error,name,varargout] = check_classification(project_path,segmentation_configs,class,varargin)
%GUI_CHECK_CLASSIFICATION checks if the selected classification is correct

    error = 1;
    name = {};
    varargout{1} = 0;
    WAITBAR = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        end
    end

    % Test is classification exists and has files
    cpath = fullfile(project_path,'Mclassification',class);
    if exist(cpath,'dir')
        files = dir(fullfile(cpath,'*.mat'));
        if isempty(files)
            errordlg('The specified classification is empty','Error');
            return;        
        end
    else
        errordlg('Cannot find specified classification','Error');
        return;
    end 

    if WAITBAR
        h = waitbar(0,'Checking selected classification...','Name','Initialization');
    end
    classifications = {};
    for i = 1:length(files)
        % see if the file can be loaded
        try
            load(fullfile(cpath,files(i).name));
        catch
            continue;
        end
        %test if the classification belongs to the selected segmentation
        a = segmentation_configs.FEATURES_VALUES_SEGMENTS;
        b = classification_configs.FEATURES;
        if size(a) ~= size(b)
            continue;
        end
        classifications{i} = classification_configs;
        clear classification_configs;
        if WAITBAR
            waitbar(i/length(files));
        end
    end
    if WAITBAR
        delete(h);
    end
    if isempty(classifications)
        errordlg('The specified classification is empty. Check if the selected segmentation is correct','Error');
        return;     
    end
    
    % output
    error = 0;
    name = class;
    varargout{1} = classifications;
end

