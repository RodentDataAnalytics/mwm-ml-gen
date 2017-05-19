function npath = MAKE_OUTPUT_FOLDER_TREE(upath,option)
%MAKE_OUTPUT_FOLDER_TREE

    if option == 1 % Master Folder        
        npath = fullfile(upath,'MASTER_TEST');
        if ~exist(npath,'dir')
            mkdir(npath);
        end
    end
    
    if option == 2 % No Smoothing Folder        
        npath = fullfile(upath,'NO_SMOOTHING');
        if ~exist(npath,'dir')
            mkdir(npath);
        end    
    end
    
    if option == -2 % Smoothing Folder    
        npath = fullfile(upath,'SMOOTHING');
        if ~exist(npath,'dir')
            mkdir(npath);
        end    
    end
    
    
end

