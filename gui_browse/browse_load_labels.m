function [error] = browse_load_labels(handles)
%BROWSE_LOAD_LABELS

    error = 1;
    % Check what kind of object is loaded
    index = get(handles.plotter,'UserData');
    if index == 0
        return;
    end    
    def_path = get(handles.browse_data,'UserData');
    
    %% SEGMENTATION OBJECT LOADED
    if index == 1  
        if ~isempty(def_path)
            [fname, pname] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels',char(def_path));
        else
            [fname, pname] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels');
        end
        if pname == 0
            return;
        end
        fpath = strcat(pname,fname);
        tmp = get(handles.trajectory_info,'UserData');
        % read the labels file
        try
            [indexes,labels] = browse_read_labels_file(fpath);
        catch
            errordlg('Cannot read file','Read error');
            return;
        end
        % check (partly) if the labels file was correct
        segs = size(tmp.FEATURES_VALUES_SEGMENTS,1);
        last = sort(indexes);
        last = last(end);
        if segs < last
            errordlg('The labels file does not apply to this segmentation','error');
            return;
        end    
        % check the tags
        num_tags = get(handles.available_tags,'String');
        [labels,indexes] = browse_check_labels(num_tags,labels,indexes);
        % save them
        set(handles.tag_box,'UserData',{indexes,labels});
        error = 0;
        
    %% CLASSIFICATION OBJECT LOADED    
    elseif index == 2
        %...
    end    
end

