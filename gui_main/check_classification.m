function [error,name,varargout] = check_classification(project_path,segmentation_configs,class,varargin)
%GUI_CHECK_CLASSIFICATION checks if the selected classification is correct

    error = 1;
    name = {};
    varargout{1} = 0;
    varargout{2} = 0;
    WAITBAR = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        end
    end

    % Test is classification exists and has files
    cpath = fullfile(project_path,'Mclassification',class);
    cpath2 = fullfile(project_path,'classification',class);
    if exist(cpath,'dir')
        CLASSIFICATION = 'ENSEMBLE';
        files = dir(fullfile(cpath,'*.mat'));
        if isempty(files)
            errordlg('The specified classification is empty','Error');
            return;        
        end
    elseif exist(cpath2,'dir')
        CLASSIFICATION = 'CLASSIFIER';
        cpath = cpath2;
        files = dir(fullfile(cpath2,'*.mat'));
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
        if WAITBAR
            waitbar(i/length(files));
        end
        if size(a,1) ~= size(b,1)
            errordlg('Selected segmentation and classification do not match','Error');
            if WAITBAR
                delete(h);
            end
            return;              
        end
        classifications{i} = classification_configs;
        clear classification_configs;
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
    varargout{2} = CLASSIFICATION;
end

