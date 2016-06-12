function [ path ] = create_cache_dir(choice, path)
%CREATE_CACHE_DIR is used to create cache folders.

switch choice   
    
    case 0
        path_ = {};
        if ~exist([path '/cache'], 'dir')
            mkdir(path,'cache');
            addpath(strcat(path,'/cache'));
        end
        path_{1} = [path '/cache'];
        path_{2} = [path '/import/original_data'];
        path = {path_{1},path_{2}};

    otherwise
        error('create_cache_dir. No such choice is available')
end

end
