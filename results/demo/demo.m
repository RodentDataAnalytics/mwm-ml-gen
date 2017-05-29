function demo(set,user_path,varargin)
%DEMO executes the processes: segmentation, labelling, classification
%and produces the results

    % Functionalities
    SEGMENTATION = 1;
    CLASSIFICATION = 1;
    MCLASSIFICATION = 1;
    % Results
    LABELLING_QUALITY = 0;
    STATISTICS = 1;
    PROBABILITIES = 1;
    % Extra
    WAITBAR = 0;
    DISPLAY = 0;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        elseif isequal(varargin{i},'DISPLAY')
            DISPLAY = varargin{i+1};
        elseif isequal(varargin{i},'SEGMENTATION')
            SEGMENTATION = varargin{i+1};    
        elseif isequal(varargin{i},'CLASSIFICATION')  
            CLASSIFICATION = varargin{i+1};
        elseif isequal(varargin{i},'MCLASSIFICATION')  
            MCLASSIFICATION = varargin{i+1};
        elseif isequal(varargin{i},'LABELLING_QUALITY')
            LABELLING_QUALITY = varargin{i+1};
        elseif isequal(varargin{i},'STATISTICS')  
            STATISTICS = varargin{i+1};
        elseif isequal(varargin{i},'PROBABILITIES')    
            PROBABILITIES = varargin{i+1};
        end
    end
    
    %Set Options
    if set == 1
        seg_overlap = [0.7,0.7,0.9,0.7];
        seg_length = [300,250,250,200];
        groups = [1,2];
        num_clusters = 10:58; %49 classifiers
        sample = 11;
        iterations = 21;
        Mclusters = num_clusters;
    elseif set == 2
        return
    end
   
    %%
    user_path = char_project_path(user_path);
    if WAITBAR
        h = waitbar(0,'Initializing...');
    end
    
    %% Create project folder tree (set_folder.m)
    if set == 1
        error = build_folder_tree(user_path, 'demo_original_set_1');
    elseif set == 2
        error = build_folder_tree(user_path, 'demo_original_set_2');
    end
    if error
        if WAITBAR
            delete(h);
        end
        return
    end
    
    if set == 1
        project_path = fullfile(user_path,'demo_original_set_1');
    elseif set == 2
        project_path = fullfile(user_path,'demo_original_set_2');
    end
    if WAITBAR
        waitbar(1/2);
    end
    
    %% Copy the settings
    if isdeployed
        if set == 1
            datapath = fullfile(ctfroot,'import','original_data_1_settings');
        elseif set == 2
            datapath = fullfile(ctfroot,'import','original_data_2_settings'); 
        end
    else
        if set == 1
            datapath =  fullfile(pwd,'import','original_data_1_settings');
        elseif set == 2
            datapath =  fullfile(pwd,'import','original_data_2_settings');
        end           
    end   
    files = dir(fullfile(datapath,'*.mat'));
    for i = 1:length(files)
        copyfile(fullfile(datapath,files(i).name),fullfile(project_path,'settings'));
    end
    ptags = fullfile(datapath,'tags.txt');
    copyfile(ptags,fullfile(project_path,'settings'));
    ptags = fullfile(datapath,'animal_groups.csv');
    copyfile(ptags,fullfile(project_path,'settings'));
    if WAITBAR
        waitbar(2/2);
        delete(h);
    end
    
    %% Segmentation
    if SEGMENTATION
        try
            load(fullfile(project_path,'settings','new_properties.mat'));
            load(fullfile(project_path,'settings','animal_groups.mat'));
            load(fullfile(project_path,'settings','my_trajectories.mat'));
            load(fullfile(project_path,'settings','my_trajectories_features.mat'));
        catch
            errordlg('Cannot load project settings','Error');
            return
        end
        for i = 1:length(seg_overlap)
            seg_properties = [seg_length(i),seg_overlap(i)];
            segmentation_configs = config_segments(new_properties, seg_properties, trajectory_groups, my_trajectories, my_trajectories_features, '');
            save_segmentation(segmentation_configs, project_path);
        end    
    end
    
    %% Labelling
    % Copy the labels csv files and generate the mat files
    lfiles = dir(fullfile(datapath,'labels','*.csv'));
    sfiles = dir(fullfile(project_path,'segmentation','*.mat'));
    for i = 1:length(sfiles)
        copyfile(fullfile(datapath,'labels',lfiles(i).name),fullfile(project_path,'labels'));
        path_labels = fullfile(project_path,'labels',lfiles(i).name);
        [~,len,ovl,~,~] = split_labels_name(path_labels);
        for j = 1:length(sfiles)
            path_segs = fullfile(project_path,'segmentation',sfiles(j).name);
            [~,~,seg_length,seg_overlap] = split_segmentation_name(path_segs);
            if isequal(seg_length,len) && isequal(seg_overlap,ovl)
                load(path_segs);
                generate_mat_from_labels(path_labels,segmentation_configs);
                break;
            end
        end
    end    
    
    %% Classification
    if CLASSIFICATION
        lfiles = dir(fullfile(project_path,'labels','*.mat'));
        for i = 1:length(lfiles)
            path_labels = fullfile(project_path,'labels',lfiles(i).name);
            [~,len,ovl,~,~] = split_labels_name(path_labels);
            for j = 1:length(sfiles)
                path_segs = fullfile(project_path,'segmentation',sfiles(j).name);
                [~,~,seg_length,seg_overlap] = split_segmentation_name(path_segs);
                if isequal(seg_length,len) && isequal(seg_overlap,ovl)
                    error = execute_classification(project_path,sfiles(j).name,lfiles(i).name,num2str(num_clusters));
                end
            end        
        end
    end
    
    %% Mclassification
    if MCLASSIFICATION
        classifs = dir(fullfile(project_path,'classification'));
        for i = 3:length(classifs)
            execute_Mclassification(project_path, {classifs(i).name}, sample, iterations, 0, 'CLUSTERS', Mclusters)
        end
    end   
    
    %% Results
    % Animal Trajectories Map
    [~, animals_trajectories_map] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman',set);
    
    % METRICS
    str = num2str(groups);
    str = regexprep(str,'[^\w'']',''); %remove gaps
    str = strcat('group',str);   
    output_dir = fullfile(project_path,'results','metrics',str);
    if ~exist(output_dir,'dir')
        mkdir(output_dir);
    end
    try
        results_latency_speed_length(new_properties,my_trajectories,my_trajectories_features,animals_trajectories_map,1,output_dir);
    catch
        errordlg('Error: metrics generation','Error');
    end
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS
    if PROBABILITIES
        b_pressed = {'Strategies','Transitions','Probabilities'};
    else
        b_pressed = {'Strategies','Transitions'};
    end
    segs = dir(fullfile(project_path,'segmentation','*.mat'));
    mclasses = dir(fullfile(project_path,'Mclassification'));
    for i = 1:length(segs)
        seg = fullfile(project_path,'segmentation',segs(i).name);
        [~,~,sl,so] = split_segmentation_name(seg);
        for j = 3:length(mclasses)
            mclass = fullfile(project_path,'Mclassification',mclasses(j).name);
            [~,~,~,seg_length,seg_overlap,~,~,~] = split_mclassification_name(mclass);
            if isequal(sl,seg_length) && isequal(so,seg_overlap)
                load(fullfile(project_path,'segmentation',segs(i).name));
                % Check the classification
                [error,name,classifications] = check_classification(project_path,segmentation_configs,mclasses(j).name, 'WAITBAR',0);
                if error
                    errordlg('Classification check failed','Error');
                    return
                end    
                % Generate the results
                for b = 1:length(b_pressed)
                    error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{b}, groups, 'WAITBAR',0);
                    if error
                        errordlg('Cannot create results for strategies, transitions and probabilities','Error');
                        return
                    end
                end     
                % Statistics
                if STATISTICS
                    [error,~,~] = class_statistics(project_path, mclasses(j).name);
                    if error
                        errordlg('Error: statistics generation','Error');
                    end  
                end
                break;
            end
        end
    end
    
    %% Labelling Quality
    if LABELLING_QUALITY
        for i = 1:length(seg_overlap)
            load(fullfile(project_path,'segmentation',seg_name(i).name));
            p = strsplit(files(i).name,'.mat');
            p = p{1};
            output_path = char(fullfile(project_path,'labels',strcat(p,'_check')));
            if ~exist(output_path,'dir')
                mkdir(output_path);
            end
            [nc,res1bare,res2bare,res1,res2,res3,covering] = results_clustering_parameters(segmentation_configs,fullfile(project_path,'labels',lab_name(i).name),0,output_path,10,100,10);
            output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation')));
            if exist(output_path,'dir');
                rmdir(output_path,'s');
            end
            mkdir(output_path);
            [nc,per_errors1,per_undefined1,coverage] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
            data = [nc', per_errors1', per_undefined1', coverage'];
            % export results to CSV file
            export_num_of_clusters(output_path,data);
            % generate graphs
            results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering);
        end
    end
end

