function exe_new_project(hObject, eventdata, handles)
    main_path = get(handles.new_project,'UserData');
    %set project name and folder
    project_path = set_project(main_path);
    if isempty(project_path)
        return;
    else
        %hide this GUI
        [temp, idx] = hide_gui('RODA');
        set(handles.load_project,'UserData',project_path);
        %load the new project
        if ~iscell(project_path) 
            project_path = {project_path};
        end
        new_project(project_path);
        project_path = char_project_path(project_path);
        files  = dir(fullfile(project_path,'settings','*.mat'));
        if isempty(files) % no data were loaded
            rmdir(project_path,'s');
            set(temp(idx),'Visible','on'); 
            return
        end
        if isdeployed
            tags_path = fullfile(ctfroot,'configs','tags','tags_default.txt');
            tags_path2 = fullfile(ctfroot,'configs','tags','tags.txt');
        else
            tags_path =  fullfile(pwd,'configs','tags','tags_default.txt'); 
            tags_path2 = fullfile(pwd,'configs','tags','tags.txt');
        end   
        copyfile(tags_path,fullfile(project_path,'settings'));
        copyfile(tags_path2,fullfile(project_path,'settings'))
        %resume this GUI's visibility
        set(temp(idx),'Visible','on'); 
        %activate everything
        set(handles.conf_tags,'Enable','on');
        set(findall(handles.panel_seg, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_lab, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_class, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.panel_res, '-property', 'enable'), 'enable', 'on');
        set(handles.paths_features,'Enable','on');
    end
end

