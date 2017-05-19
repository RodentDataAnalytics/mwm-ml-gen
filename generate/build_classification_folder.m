function [class_folder,error] = build_classification_folder(ppath,prefix,labels,segs,len,ovl,varargin)
%BUILD_CLASSIFICATION_FOLDER creates the folder of the classifiers 

    note = '';
    if ~isempty(varargin)
        note = varargin{1};
    end
    if ~isempty(note)
        class_folder = fullfile(ppath,'classification',strcat(prefix,'_',labels,'_',segs,'_',len,'_',ovl,'-',note));
    else
        class_folder = fullfile(ppath,'classification',strcat(prefix,'_',labels,'_',segs,'_',len,'_',ovl));
    end
    
    try
        if exist(class_folder,'dir')
            choice = questdlg('Default classifiers already exist would you like to re-generate them or add more to the pool?','Folder exists','Add','Re-generate','Cancel','Add');
            if isequal(choice,'Re-generate')
                fclose('all');
                rmdir(class_folder,'s');
                mkdir(class_folder);
                error = 0;
                return
            elseif isequal(choice,'Add')
                error = 0;
                return
            else
                error = 2;
            end
        else
            mkdir(class_folder);
            error = 0;
        end
    catch
        error = 1;
    end
end

