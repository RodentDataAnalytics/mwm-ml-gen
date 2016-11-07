function [error,project_path,varargout] = gui_check_segmentation(handles)
%CHECK_SEGMENTATION checks if a segmentation object is selected and loaded

    error = 1;
    varargout{1} = 0;
    
    project_path = char(get(handles.load_project,'UserData'));
    if isempty(project_path)
        errordlg('No project is loaded','Error');
        return;
    end
    segmentation = get(handles.default_segmentation,'String');
    idx = get(handles.default_segmentation,'Value');
    segmentation = segmentation{idx};
    if isempty(segmentation)
        errordlg('No segmentation is selected','Error');
        return;
    end
    path = fullfile(project_path,'segmentation',segmentation);
    try
        load(path)
        varargout{1} = segmentation_configs;
    catch
        errordlg('Cannot laod segmentation','Error');
        return;
    end
    error = 0;
end

