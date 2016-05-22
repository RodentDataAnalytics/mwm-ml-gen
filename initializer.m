function path = initializer(varargin)
%INITIALIZER setup the paths and initializes the WEKA library

    main_path = cd(fileparts(mfilename('fullpath')));
    addpath(genpath(main_path));

    %% Make cache folder tree %%
    path = create_cache_dir(0, main_path);
    addpath(genpath(main_path));
    
end

