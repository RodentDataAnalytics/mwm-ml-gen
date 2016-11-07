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
            choice = questdlg('Default classifiers already exist would you like to re-generate them?','Folder exists','Yes','No','No');
            if isequal(choice,'Yes')
                rmdir(class_folder,'s');
                mkdir(class_folder);
                error = 0;
                return
            end
            error = 2;
        else
            mkdir(class_folder);
            error = 0;
        end
    catch
        error = 1;
    end
end

