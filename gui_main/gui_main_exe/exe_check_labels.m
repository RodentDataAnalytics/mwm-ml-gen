function exe_check_labels(hObject, eventdata, handles)

    project_path = get(handles.load_project,'UserData');
    if isempty(project_path)
        errordlg('No project is currently loaded','Error');
        return
    end
    % Load segmentation_config and labels
    seg_name = get(handles.default_segmentation,'String');
    idx = get(handles.default_segmentation,'Value');
    seg_name = seg_name{idx};
    lab_name = get(handles.default_labels,'String');
    idx = get(handles.default_labels,'Value');
    lab_name = lab_name{idx};
    if isempty(seg_name) || isempty(lab_name)
        errordlg('A segmentation and a labels files need to be selected','Error');
        return;
    end
    labels = char(fullfile(project_path,'labels',lab_name));
    try
        load(labels)
    catch
        errordlg('Cannot load labels file','Error');
        return
    end  
    segs = char(fullfile(project_path,'segmentation',seg_name));
    try
        load(segs)
    catch
        errordlg('Cannot load segmentation file','Error');
        return
    end
    if ~isequal(length(segmentation_configs.SEGMENTS.items),length(LABELLING_MAP))
        errordlg('The selected segmentation do not match with the selected labelling','Error');
        return    
    end
    [~,~,seg_length,seg_overlap] = split_segmentation_name(seg_name);
    if isequal(seg_length,'0') || isequal(seg_overlap,'0')
        msgbox('Classification cannot be performed on the full swimming paths','Info');
        return
    end
    % Run the cross-validation process
    [temp, idx] = hide_gui('RODA');
    p = strsplit(lab_name,'.mat');
    p = p{1};
    [s,e,step,options] = cross_validation_clusters;
    if e == -1 || s == -1 || step == -1
        set(temp(idx),'Visible','on'); 
        return
    end
    output_path = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
    if ~exist(output_path,'dir')
        mkdir(output_path);
    else
        choice = questdlg('Checking has already been performed would you like to rerun it?','Cross-validation','No','Yes','Generate graphs only','Generate graphs only');
        if isequal(choice,'No')
            set(temp(idx),'Visible','on'); 
            return;
        elseif isequal(choice,'Yes')
            rmdir(output_path,'s');
            mkdir(output_path); 
        elseif isequal(choice,'Generate graphs only')
        end
    end
    %[nc,res1bare,res2bare,res1,res2,res3,covering] = results_clustering_parameters(segmentation_configs,labels,0,output_path,s,e,step);
    [nc,res1bare,res2bare,res1,res2,res3,covering] = cross_validation(segmentation_configs,labels,10,[s,e,step],output_path,options,0);
    output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation'),options));
    if exist(output_path,'dir');
        rmdir(output_path,'s');
    end
    mkdir(output_path);
    [nc,per_errors1,per_undefined1,coverage,per_errors1_true] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
    data = [nc', per_errors1', per_undefined1', coverage', per_errors1_true'];
    % export results to CSV (inside the results and the labels folders
    export_num_of_clusters(output_path,data);
    output_path2 = char(fullfile(project_path,'labels',strcat(p,'_check'),options));
    export_num_of_clusters(output_path2,data);
    % generate graphs
    results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering);
    set(temp(idx),'Visible','on'); 

end

