function weka_init
    persistent wekajarpath;
    if isempty(wekajarpath)
        wekajarpath = fullfile(fileparts(mfilename('fullpath')), 'weka.jar');
        javaaddpath(wekajarpath);        
        javaaddpath(fullfile(fileparts(mfilename('fullpath')), 'Jama-1.0.3.jar'));
        javaaddpath(fullfile(fileparts(mfilename('fullpath'))));
    end    
end
