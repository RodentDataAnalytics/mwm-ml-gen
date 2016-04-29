function [ path ] = create_cache_dir(choice, path)
%CREATE_CACHE_DIR is used to create cache folders.
% The cache 'folder_name' is created inside '...\path\'. 
% Path 'path\'folder_name' is returned.

switch choice   
    case 1 % create cache folder
        if ~exist([path '\cache'], 'dir')
            mkdir(path,'cache');
        end
        path = [path '\cache'];
        
    case 2 % create features folder (trajectories)
        if ~exist([path '\features'], 'dir')
            mkdir(path,'features');
        end
        path = [path '\features'];
        
    otherwise
        error('create_cache_dir. No such choice available')
end



end

