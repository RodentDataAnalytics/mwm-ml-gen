function initializer
%INITIALIZER setup the paths and initializes the WEKA library

main_path = cd(fileparts(mfilename('fullpath')));
addpath(genpath(main_path));

%% Initialize the WEKA library %%
weka_init;
disp('Weka library now initialized. Cheers.');

end

