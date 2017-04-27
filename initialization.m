function [main_path] = initialization
%INITIALIZATION adds all the necessary files to MATLAB path, starts the
%WEKA library and creates the default folder MWMGEN inside the documents
%folder

    %% Set main path
    if ~isdeployed
        main_path = cd(fileparts(mfilename('fullpath')));
        addpath(genpath(main_path));
    else
        %main_path = ctfroot;
    end    

    %% Generate default folder
    %get special folder 'Documents' as char
    if ismac
        doc_path = char(java.lang.System.getProperty('user.home'));
        doc_path = fullfile(doc_path,'Documents');
    else
        doc_path = char(getSpecialFolder('MyDocuments'));
    end
    main_path = fullfile(doc_path,'MWMGEN');
    %make the default folder if it does not exist
    if ~exist(main_path,'dir')
        mkdir(main_path);
    end
    
    %make the folder for storing default tags
    fpath = fullfile(main_path,'custom_tags');
    if ~exist(fpath,'dir')
        mkdir(fpath);
    end   
    
    %% Start WEKA
    weka_init;
end

