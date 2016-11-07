function char_ppath = char_project_path(ppath)
%CHAR_PROJECT_PATH returns the full project path as char

    if iscell(ppath)
        ppath = ppath{1};
    end
    if ~ischar(ppath);
        ppath = char(ppath);
    end
    char_ppath = ppath;
end

