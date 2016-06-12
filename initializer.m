function path = initializer(varargin)
%INITIALIZER setup the paths and initializes the WEKA library

    if ~isdeployed
        main_path = cd(fileparts(mfilename('fullpath')));
        addpath(genpath(main_path));
    else
        main_path = ctfroot;
    end    

    %% Make cache folder tree %%
    path = create_cache_dir(0, main_path);
    if ~isdeployed
        addpath(genpath(main_path));
    end
end

