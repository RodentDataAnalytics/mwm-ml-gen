function [error] = browse_save_labels(handles,varargin)
%BROWSE_SAVE_LABELS

    error = 1;
    % Check what kind of object is loaded
    index = get(handles.plotter,'UserData');
    if index == 0
        return;
    end    
    
    for i = 1:length(varargin) % runs if mode=1 and trajectory is selected
        if isequal(varargin{i},'index')
            index = varargin{i+1};
        end
    end
    
    %% SEGMENTATION OBJECT LOADED
    if index == 1  
        labels = get(handles.tag_box,'UserData');
        if isempty(labels)
            return
        end
        if isempty(labels{1})
            return
        end
        % convert double array to array of cells
        segs =  cellstr(num2str(labels{1}));
        % make a new array of cells
        labels_ = cell(size(labels{2},1),size(labels{2},2)+1);
        % store segments and labels
        labels_(:,1) = segs(:,1);
        labels_(:,2:end) = labels{2}(:,1:end);
        % make sure we do not have emtpy labels
        tmp = find(cellfun(@isempty,labels_(:,2))==1);
        labels_(tmp,:) = [];
        % sort by segment number
        labels_ = sortrows(labels_,1);
        % make the header
        VariableNames = cell(1,size(labels_,2));
        VariableNames{1} = 'Segment';
        for i = 2:length(VariableNames)
            VariableNames{i} = strcat('label',num2str(i-1));
        end
        % convert to table
        labels_ = cell2table(labels_,'VariableNames',VariableNames);
        % write to CSV file
        %generate default name
        name = get(handles.trajectory_info,'UserData');
        p1 = num2str(name.SEGMENTATION_PROPERTIES(1));
        p2 = num2str(name.SEGMENTATION_PROPERTIES(2));
        p2(regexp(p2,'[.]')) = []; %remove the dot.
        p3 = num2str(size(segs,1)); %number of labels
        name = strcat(p3,'_',p1,'_',p2);
        %generate default path
        def_path = get(handles.browse_data,'UserData');
        if ~isempty(def_path)
            def_path = fullfile(def_path,'labels');
            [error,fpath] = browse_create_labels_file(labels_,name,def_path);
        else
            [error,fpath] = browse_create_labels_file(labels_);
        end
        if error || isequal(fpath,0)
            return
        end    
        % create the .mat file
        if ~isempty(get(handles.browse_data,'UserData'))
            segmentation_configs = get(handles.trajectory_info,'UserData');
            generate_mat_from_labels(fpath,segmentation_configs);
        end
        error = 0;
        
        %rerun for the trajectories
        error = browse_save_labels(handles,'index',3);
        
    %% CLASSIFICATION OBJECT LOADED    
    elseif index == 2
        %...
    
    %% MY_TRAJECTORIES OBJECT LOADED        
    elseif index == 3  
        labels = get(handles.listbox,'UserData');
        if isempty(labels)
            return
        end
        if isempty(labels{1})
            return
        end
        % convert double array to array of cells
        segs =  cellstr(num2str(labels{1}));
        % make a new array of cells
        labels_ = cell(size(labels{2},1),size(labels{2},2)+1);
        % store segments and labels
        labels_(:,1) = segs(:,1);
        labels_(:,2:end) = labels{2}(:,1:end);
        % make sure we do not have emtpy labels
        tmp = find(cellfun(@isempty,labels_(:,2))==1);
        labels_(tmp,:) = [];        
        % sort by segment number
        labels_ = sortrows(labels_,1);
        % make the header
        VariableNames = cell(1,size(labels_,2));
        VariableNames{1} = 'Trajectory';
        for i = 2:length(VariableNames)
            VariableNames{i} = strcat('label',num2str(i-1));
        end
        % convert to table
        labels_ = cell2table(labels_,'VariableNames',VariableNames);
        % write to CSV file
        %generate default name
        p1 = '0';
        p2 = '0';
        p2(regexp(p2,'[.]')) = []; %remove the dot.
        p3 = num2str(size(segs,1)); %number of labels
        name = strcat(p3,'_',p1,'_',p2);
        %generate default path
        def_path = get(handles.browse_data,'UserData');
        if ~isempty(def_path)
            def_path = fullfile(def_path,'labels');
            [error,fpath] = browse_create_labels_file(labels_,name,def_path);
        else
            [error,fpath] = browse_create_labels_file(labels_);
        end
        if error || isequal(fpath,0)
            return
        end    
        % create the .mat file
        if ~isempty(get(handles.browse_data,'UserData'))
            my_trajectories = get(handles.trajectory_info,'UserData');
            generate_mat_from_labels(fpath,my_trajectories);
        end
        error = 0;
    end   
end

