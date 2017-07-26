function exe_default_classification(hObject, eventdata, handles)
    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        return;
    end
    % Hide GUI and execute
    [temp, idx] = hide_gui('RODA');
    seg_name = get(handles.default_segmentation,'String');
    tmp = get(handles.default_segmentation,'Value');
    seg_name = seg_name{tmp};
    lab_name = get(handles.default_labels,'String');
    tmp = get(handles.default_labels,'Value');
    lab_name = lab_name{tmp};
    ret = get(handles.classification_conf,'UserData');
    error = default_classification(project_path,seg_name,lab_name,ret);
    if error == 2 %perform cv first 
        options = 'labels';
        p = strsplit(lab_name,'.mat');
        p = p{1};
        output_path = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
        mkdir(output_path);
        labels = char(fullfile(project_path,'labels',lab_name));
        load(char(fullfile(project_path,'segmentation',seg_name)));
        if ret(6) == 0
            load(labels);
            tags = unique(cell2mat(LABELLING_MAP));
            tmp = find(tags <= 0);
            tags = length(tags) - length(tmp) + 2;
        end
        [nc,res1bare,res2bare,res1,res2,res3,covering] = cross_validation(segmentation_configs,labels,10,[tags,ret(2),1],output_path,options,0);
        output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation'),options));
        mkdir(output_path);
        [nc,per_errors1,per_undefined1,coverage,per_errors1_true] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
        data = [nc', per_errors1', per_undefined1', coverage', per_errors1_true'];
        % export results to CSV (inside the results and the labels folders)
        export_num_of_clusters(output_path,data);
        output_path2 = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
        export_num_of_clusters(output_path2,data);     
        error = default_classification(project_path,seg_name,lab_name,ret);
    elseif error == 1
        set(temp(idx),'Visible','on');
        return
    end
    set(temp(idx),'Visible','on');
    if ~error
        msgbox('Operation successfully completed','Success');
    end      
end

