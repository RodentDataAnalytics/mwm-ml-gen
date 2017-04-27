function [error] = browse_load_labels(handles)
%BROWSE_LOAD_LABELS

    error = 1;
    % Check what kind of object is loaded
    mode = get(handles.plotter,'UserData');
    if mode == 0
        return;
    end    
    def_path = get(handles.browse_data,'UserData');
    
    %% SEGMENTATION OBJECT LOADED
    if mode == 1  
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
            [indexes,labels,header] = browse_read_labels_file(fpath);
        catch
            errordlg('Cannot read file','Read error');
            return;
        end
        % check (partly) if the labels file was correct
        last = sort(indexes);
        last = last(end);
        trajs = length(tmp.TRAJECTORIES.items);
        segs = size(tmp.FEATURES_VALUES_SEGMENTS,1);
        if trajs < last
            if segs < last
                errordlg('The labels file does not apply to this segmentation','error');
                return;
            end
        end         
        % check the tags
        num_tags = get(handles.available_tags,'String');
        [labels,indexes] = browse_check_labels(num_tags,labels,indexes);
        % save them
        if isequal(header,'S')
            set(handles.tag_box,'UserData',{indexes,labels});
        else
            set(handles.listbox,'UserData',{indexes,labels});
        end
        error = 0;
        
    %% CLASSIFICATION OBJECT LOADED    
    elseif mode == 2
        %...
   
    %% MY_TRAJECTORIES OBJECT LOADED       
    elseif mode == 3 
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
        traj = length(tmp.items);
        last = sort(indexes);
        last = last(end);
        if traj < last
            errordlg('The labels file does not apply to this segmentation','error');
            return;
        end    
        % check the tags
        num_tags = get(handles.available_tags,'String');
        [labels,indexes] = browse_check_labels(num_tags,labels,indexes);
        % save them
        set(handles.listbox,'UserData',{indexes,labels});
        error = 0;            
    end    
end

