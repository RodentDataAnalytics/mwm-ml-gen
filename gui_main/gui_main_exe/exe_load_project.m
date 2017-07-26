function exe_load_project( hObject, eventdata, handles )
    
    main_path = get(handles.new_project,'UserData');
    [~,ppath] = uigetfile({'*.cfg','CONFIG-file (*.cfg)'},'Select configuration file',main_path{1});
    if isequal(ppath,0)
        return
    end
    set(handles.load_project,'UserData',{ppath});
    %check if we have the tags
    tpath1 = fullfile(ppath,'settings','tags_default.txt');
    tpath2 = fullfile(ppath,'settings','tags.txt');
    if ~exist(tpath1,'file') || ~exist(tpath2,'file')
        if isdeployed
            tags_path = fullfile(ctfroot,'configs','tags','tags_default.txt');
            tags_path2 = fullfile(ctfroot,'configs','tags','tags.txt');
        else
            tags_path =  fullfile(pwd,'configs','tags','tags_default.txt'); 
            tags_path2 = fullfile(pwd,'configs','tags','tags.txt');
        end   
        copyfile(tags_path,fullfile(ppath,'settings'));
        copyfile(tags_path2,fullfile(ppath,'settings'))        
    end
    %activate everything
    set(handles.conf_tags,'Enable','on');
    set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'on');
    set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'on');
    %set(handles.paths_features,'Enable','on');
end

