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
    
    case 1 % create cache folder
        if ~exist([path '/cache'], 'dir')
            mkdir(path,'cache');
            addpath(strcat(path,'/cache'));
        end
        path = [path '/cache'];
        
    case 2 % create test folder
        if ~exist([path '/cache'], 'dir')
            mkdir(path,'cache');
            addpath(strcat(path,'/cache'));
        end
        path = [path '/cache'];
        if ~exist([path '/original_results'], 'dir')
            mkdir(path,'original_results');
            addpath(strcat(path,'/original_results'));
        end
        path = [path '/original_results'];
        
    otherwise
        error('create_cache_dir. No such choice is available')
end



end

