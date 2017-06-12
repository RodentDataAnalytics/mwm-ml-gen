function [Mclass_folder,error] = build_Mclassification_folder(class_folder,classifiers,iterations,technique,varargin)
%BUILD_MCLASSIFICATION_FOLDER creates the folder of the merged classifiers

%CASE 1 CLASSIFIERS GROUP
% prefix_labels_segs_len_ovl_numClass_iter_tech_note
%CASE 2 MULTIPLE CLASSIFIERS GROUPS
% prefix_labels(.)_segs(.)_len(1)_ovl(.)_numClass_iter_tech_note(no gaps)

    SPECIAL = 0;
    for i = 1:length(varargin)
        if isequal(varargin{i},'SPECIAL');
            SPECIAL = 1;
            SPECIAL_STR = varargin{i+1};
        end
    end
            
    Mclass_folder = {};
    
    if iscell(class_folder)
        prefix = {};
        labels = {};
        segs = {};
        len = {};
        ovl = {};
        note = {};
        for i = 1:length(class_folder)
            [pathstr,name,~] = fileparts(class_folder{i});
            ppath = fileparts(pathstr);
            subname = strsplit(name,{'_','-'});
            prefix = [prefix,subname{1}];
            labels = [labels,subname{2}];
            segs = [segs,subname{3}];
            len = [len,subname{4}];
            ovl = [ovl,subname{5}];
            if length(subname) > 5
                note = [note,subname{6}];
            end           
        end
        % check if we have the same length
        lens = len{1};
        for i = 2:length(len)
            if ~isequal(lens,len{i})
                error = 1;
                return
            end
        end
        prefix = prefix{1}; % just use one prefic for now
        labels = strjoin(labels,'.');
        segs = strjoin(segs,'.');
        len = len{1};
        ovl = strjoin(ovl,'.'); 
        note = strjoin(note,''); 
    else
        [pathstr,name,~] = fileparts(class_folder);
        ppath = fileparts(pathstr);
        subname = strsplit(name,{'_','-'});

        prefix = subname{1};
        labels = subname{2};
        segs = subname{3};
        len = subname{4};
        ovl = subname{5};
        note = '';
        if length(subname) > 5
            note = subname{6};
        end
    end
    
    if ~isempty(note)
        Mclass_folder = fullfile(ppath,'Mclassification',strcat(prefix,'_',labels,'_',segs,'_',len,'_',ovl,'_',...
            classifiers,'_',iterations,'_',technique,'-',note));
    else
        Mclass_folder = fullfile(ppath,'Mclassification',strcat(prefix,'_',labels,'_',segs,'_',len,'_',ovl,'_',...
            classifiers,'_',iterations,'_',technique));
    end
    
    if SPECIAL
        Mclass_folder = strcat(Mclass_folder,SPECIAL_STR);
    end
    
    try
        if exist(Mclass_folder,'dir')
            rmdir(Mclass_folder,'s');
        end
        mkdir(Mclass_folder);
        error = 0;
    catch
        error = 1;
    end
end

