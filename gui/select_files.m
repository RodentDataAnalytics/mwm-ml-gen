function [ return_data ] = select_files( option )
%SELECT_FILES asks the user to specify the file's path and return if it is
%correct.

    return_data = {};
    
    switch option
        case 1 % segmentation_configs
            error = 1;
            while error
                [FN_group,PN_group] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select a segmentation configurations file');
                if isequal(PN_group,0)
                    return;
                end 
                load(strcat(PN_group,FN_group));
                if exist('segmentation_configs')
                    if isa(segmentation_configs,'config_segments')
                        error=0;
                    else
                        errordlg('Wrong file selected. Select a segmentation_configs .mat file.');
                        return
                    end
                else
                    errordlg('Wrong file selected. Select a segmentation_configs .mat file.');
                    return
                end
            end 
            %check if segmentation_configs has the correct output path
            %and if not ask the user to specify one.
            error = check_object_output_dir(1, FN_group,PN_group);
            if error == 1
                errordlg('File path for segmentation configurations not found.','Input Error');
                return
            elseif error == 2
                errordlg('Wrong MAT file was selected.','Input Error');
                return
            end    
            %reload
            load(strcat(PN_group,FN_group));
            return_data = {segmentation_configs,[PN_group,FN_group]};
            
        case 2 % labels data
            error = 1;
            while error
                [FN_group,PN_group] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select a labels file.');
                if isequal(PN_group,0)
                    return;
                end 
                if exist(strcat(PN_group,FN_group),'file') == 2
                    error = 0;
                else
                    errordlg('Selectd file is invalid. Select a csv file containing labelling data.');
                    return
                end
            end 
            return_data = strcat(PN_group,FN_group);
            
        case 3 % classification_configs
            error = 1;
            while error
                [FN_group,PN_group] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select a classification configurations file');
                if isequal(PN_group,0)
                    return;
                end 
                load(strcat(PN_group,FN_group));
                if exist('classification_configs')
                    if isa(classification_configs,'config_classification')
                        error=0;
                    else
                        errordlg('Wrong file selected. Select a classification_configs .mat file.');
                        return
                    end
                else
                    errordlg('Wrong file selected. Select a classification_configs .mat file.');
                    return
                end
            end  
            return_data = {classification_configs,[PN_group,FN_group]};
            
        case 4 % folds
            prompt={'Choose number of folds'};
            name = 'Folds';
            defaultans = {''};
            options.Interpreter = 'tex';
            user = inputdlg(prompt,name,[1 30],defaultans,options);
            error = 1;
            while error
                if isempty(user)
                    return
                else
                    if isempty(str2num(user{1,1}))
                        errordlg('Wrong input, insert a number to specify the N-fold cross-validation.');
                    else
                        return_data = user;
                        return
                    end
                end
            end
    end
end

