function [error,project_path,seg_name,lab_name] = initialize_classification(handles,eventdata)
%INITIALIZE_CLASSIFICATION checks if we require classification of the full
%trajectories and creates a dummy segmentation object

    seg_name = '';
    lab_name = '';
    error = 1;
    
    if isa(handles,'trajectories')
        [pathstr,lab_name,~] = fileparts(eventdata); %labels file
        project_path = fileparts(pathstr);
        t = strsplit(lab_name,'_');
        if isequal(t{3},'0') && isequal(t{4},'0')
            % Check if we have dummy segmenation configs file and if not
            % make it
            tmp = strcat('segmentation_configs_',t{2},'_',t{3},'_',t{4},'.mat');
            if exist(fullfile(project_path,'segmentation',tmp),'file')
                seg_name = tmp;
            else
                uiwait(msgbox('A segmentation object will be created for the full trajectories. This object can be selected from the Default Segmentation dropbox.','Info','modal'));
                error = execute_segmentation(project_path,0,0,'dummy');
                seg_name = tmp;
            end
        end
        return
    end
    
    if isequal(eventdata.Source.String,'Default')
        project_path = char_project_path(get(handles.classification_adv,'UserData'));
        if isempty(project_path)
            error_messages(8)
            return
        end
        % Load segmentation_config and labels
        seg_name = get(handles.default_segmentation,'String');
        idx = get(handles.default_segmentation,'Value');
        seg_name = seg_name{idx};
        lab_name = get(handles.default_labels,'String');
        idx = get(handles.default_labels,'Value');
        lab_name = lab_name{idx};
        if isempty(lab_name)
            error_messages(9)
            return;
        end
        t = strsplit(lab_name,{'_','.mat'});
        if isequal(t{3},'0') && isequal(t{4},'0')
            % Check if we have dummy segmenation configs file and if not
            % make it
            tmp = strcat('segmentation_configs_',t{2},'_',t{3},'_',t{4},'.mat');
            if exist(fullfile(project_path,'segmentation',tmp),file)
                seg_name = tmp;
            else
                error = execute_segmentation(project_path,0,0,'dummy');
            end
        else % check if a segmentation is selected
            if isempty(seg_name)
                error_messages(10);
                return;
            end
        end
        
    elseif isequal(eventdata.Source.String,'Generate Classifiers')  
        project_path = char_project_path(get(handles.classification_adv,'UserData'));
        if isempty(project_path)
            error_messages(8);
            return
        end
        %get labels
        idx = get(handles.select_labels,'Value');
        lab_name = get(handles.select_labels,'String');
        lab_name = lab_name{idx};    
        if isempty(lab_name)
            error_messages(9);
            return;
        end
        t = strsplit(lab_name,{'_','.mat'});
        if isequal(t{3},'0') && isequal(t{4},'0')
            % Check if we have dummy segmenation configs file and if not
            % make it
            tmp = strcat('segmentation_configs_',t{2},'_',t{3},'_',t{4},'.mat');
            if exist(fullfile(project_path,'segmentation',tmp),'file')
                seg_name = tmp;
            else
                error = execute_segmentation(project_path,0,0,'dummy');
                seg_name = tmp;
            end
        else % check if a segmentation is selected
            %get selected segmentation
            idx = get(handles.select_segmentation,'Value');
            seg_name = get(handles.select_segmentation,'String');
            seg_name = seg_name{idx};
            if isempty(seg_name)
                error_messages(10);
                return;
            end
        end
        error = 0;
    end
end

