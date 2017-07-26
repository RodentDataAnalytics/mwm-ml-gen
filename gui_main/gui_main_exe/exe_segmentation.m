function exe_segmentation(hObject, eventdata, handles)

    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end    
    seg_length = get(handles.seg_length,'String');
    seg_overlap = get(handles.seg_overlap,'String');
    error = check_segmentation_properties(seg_length,seg_overlap);
    if error
        return;
    end
    seg_length = str2double(seg_length);
    seg_overlap = unique(str2num(seg_overlap));
    [temp, idx] = hide_gui('RODA');
    error = execute_segmentation(project_path,seg_length,seg_overlap);
    set(temp(idx),'Visible','on'); 
    if ~error
        msgbox('Operation successfully completed','Success');
    end
end

