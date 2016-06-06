function [ error, return_data ] = select_files_default( option, rpath )
%SELECT_FILES_DEFAULT checks if the path of the objects is correct, and
%loads the objects

    switch option
    case 1 % segmentation configs
        error = 1;
        return_data = {};
        if exist(rpath, 'file') == 2 % check if file exists
            ext = regexp(rpath, '\.', 'split'); 
            if isequal(ext{1,end},'mat') || isequal(ext{1,end},'MAT') % check file's extension
                load(rpath);
                if exist('segmentation_configs')
                    if isa(segmentation_configs,'config_segments')
                        error=0;
                    end
                end
            end
        end    
        if error
            disp('Segmentation configurations file not found. Please provide a valid path for this file.');
            return
        end    
        return_data = segmentation_configs;
    
    case 2 % labels file
        error = 1;
        return_data = {};
        if exist(rpath, 'file') == 2 % check if file exists
            ext = regexp(rpath, '\.', 'split'); 
            if isequal(ext{1,end},'csv') || isequal(ext{1,end},'CSV') % check file's extension
                error=0;
            end
        end    
        if error
            disp('Labels file not found. Please provide a valid path for this file.');
            return
        end     
        return_data = rpath;
        
    case 3 % classification configs  
        error = 1;
        return_data = {};
        if exist(rpath, 'file') == 2 % check if file exists
            ext = regexp(rpath, '\.', 'split'); 
            if isequal(ext{1,end},'mat') || isequal(ext{1,end},'MAT') % check file's extension
                load(rpath);
                if exist('classification_configs')
                    if isa(classification_configs,'config_classification')
                        error=0;
                    end
                end
            end
        end   
        if error
            disp('Classification configurations file not found. Please provide a valid path for this file.');
            return
        end 
        return_data = classification_configs;
    
    end   
end

