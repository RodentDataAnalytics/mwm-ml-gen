function [error,project_path,seg_name,lab_name,numbers] = initialize_classification(handles,varargin)
%INITIALIZE_CLASSIFICATION checks if we require classification of the full
%trajectories and creates a dummy segmentation object

    seg_name = '';
    lab_name = '';
    error = 1;
    TEST_NUM_CLUSTERS = 1;
    numbers = -1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'TEST_NUM_CLUSTERS')
            TEST_NUM_CLUSTERS = varargin{i+1};
        end
    end
    
    if isstruct(handles) % Run through GUI
        sel_labels = get(handles.select_labels,'String'); 
        tmp = get(handles.select_labels,'Value'); 
        sel_labels = sel_labels{tmp};
        sel_segmentation = get(handles.select_segmentation,'String');
        tmp = get(handles.select_segmentation,'Value');
        sel_segmentation = sel_segmentation{tmp};
        num_clusters = get(handles.default_clusters,'String');
        project_path = get(handles.classification_adv,'UserData');
    else % Run through function
        sel_labels = handles{1};
        sel_segmentation = handles{2};
        num_clusters = handles{3};
        project_path = handles(4);
    end
    
    %check if project is loaded
    project_path = char_project_path(project_path);
    if isempty(project_path)
        return
    end
    
    %check if labels or segmentation fields are empty
    if isequal(sel_labels,'<no labels>') || isequal(sel_labels,'') || isequal(sel_segmentation,'')    
        return
    end
    
    %check if labels and segmentation match
    [Lnum,Llen,Lovl,~,~] = split_labels_name(sel_labels);
    [~,Snum,Slen,Sovl] = split_segmentation_name(sel_segmentation);
    
    if isequal(Slen,'0') || isequal(Sovl,'0')
        msgbox('Classification cannot be performed on the full swimming paths','Info');
        return
    end
    
    if ~isequal(Slen,Llen) && ~isequal(Lovl,Sovl)
        errordlg('Selected segmentation and labelling do not match.','Error');
        return
    end
        
    %check number of clusters
    if isequal(Lnum,Snum)
        numbers = -1; %in case Nlabels = Nsegments
    else
        try
            load(fullfile(project_path,'labels',sel_labels));
        catch
            errordlg('Cannot load selected labels.','Error');
            return
        end
        if TEST_NUM_CLUSTERS
            [error,numbers,removed] = check_num_of_clusters(num_clusters,LABELLING_MAP);
            if error == 1
                errordlg('All classifiers have been removed.','Error');
                return
            elseif error == 2
                return
            end
            if ~isempty(removed)
                str = strcat('The following classifiers have been excluded:',num2str(removed));
                msgbox(str,'Info');
            end
        else
            numbers = num_clusters;
        end
    end
    
    seg_name = sel_segmentation;
    lab_name = sel_labels;
    error = 0;
    fclose('all');
end

