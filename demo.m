function demo(set,user_path,varargin)
%DEMO executes the processes: segmentation, labelling, classification
%and produces the results

%How to run standalone (everything, no UI, no display):
% demo(1,'C:\','WAITBAR',0,'DISPLAY',0,'SEGMENTATION',1,...
%    'CLASSIFICATION',1,'MCLASSIFICATION',1,'LABELLING_QUALITY',1,'STATISTICS',1,'PROBABILITIES',1);


    if isempty(varargin)
        initialization;
    else
        if ~isequal(varargin{1},'NO_INIT')
            initialization;
        end
    end

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
    
    %% Load the settings
    try
        load(fullfile(project_path,'settings','new_properties.mat'));
        load(fullfile(project_path,'settings','animal_groups.mat'));
        load(fullfile(project_path,'settings','my_trajectories.mat'));   
        full_trajectory_features(project_path,'WAITBAR',WAITBAR,'DISPLAY',DISPLAY); % Trajectories
        load(fullfile(project_path,'settings','my_trajectories_features.mat'));
    catch
        errordlg('Cannot load project settings','Error');
        return
    end        
    
    %% Segmentation
    if SEGMENTATION
        for i = 1:length(seg_overlap)
            seg_properties = [seg_length(i),seg_overlap(i)];
            segmentation_configs = config_segments(new_properties, seg_properties, trajectory_groups, my_trajectories, my_trajectories_features, '', 'WAITBAR',WAITBAR,'DISPLAY',DISPLAY);
            save_segmentation(segmentation_configs, project_path);
        end    
    end
    
    %% Labelling
    % Copy the labels csv files and generate the mat files
    lfiles = dir(fullfile(datapath,'labels','*.csv'));
    sfiles = dir(fullfile(project_path,'segmentation','*.mat'));
    for i = 1:length(lfiles)
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

    %% Animal Trajectories Map
    [~, animals_trajectories_map, animals_ids] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman',set);
       
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
                    if isequal(seg_length,'0') && isequal(seg_overlap,'0')
                        %Generate full trajectories results
                        [~,tmp1] = fileparts(path_segs);
                        [~,tmp2] = fileparts(path_labels);
                        results_strategies_distributions_manual_full(project_path,tmp1,tmp2,animals_trajectories_map,1);
                        break;
                    end
                    %read the cv file
                    cv_file = fullfile(datapath,'cv',strcat('cv_',seg_length,'_',seg_overlap,'.csv'));
                    data = read_cv_file(cv_file);
                    data = data(:,[1,2,5]);
                    cvErr = find(data(:,3) < 25);
                    num_clusters = data(cvErr,1);    
                    error = execute_classification(project_path,sfiles(j).name,lfiles(i).name,num_clusters,varargin{:});
                end
            end        
        end
    end
    
    %% Mclassification
    if MCLASSIFICATION
        classifs = dir(fullfile(project_path,'classification'));
        for i = 3:length(classifs)
            %execute_Mclassification(project_path, {classifs(i).name}, sample, iterations, 0, 'CLUSTERS', Mclusters)
            tmp = dir(fullfile(project_path,'classification',classifs(i).name,'*.mat'));
            execute_Mclassification(project_path, {classifs(i).name}, length(tmp), 1, 0, varargin{:});
        end
    end   
    
    %% Results
    % METRICS
    str = num2str(groups);
    str = regexprep(str,'[^\w'']',''); %remove gaps
    str = strcat('group',str);   
    output_dir = fullfile(project_path,'results','metrics',str);
    if ~exist(output_dir,'dir')
        mkdir(output_dir);
    end
    try
        results_latency_speed_length(new_properties,my_trajectories,my_trajectories_features,animals_trajectories_map,1,output_dir,'DISPLAY', DISPLAY);
    catch
        errordlg('Error: metrics generation','Error');
    end
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS (Ensemble)
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
        if isequal(sl,'0') || isequal(so,'0')
            continue;
        end        
        for j = 3:length(mclasses)
            mclass = fullfile(project_path,'Mclassification',mclasses(j).name);
            [~,~,~,seg_length,seg_overlap,~,~,~] = split_mclassification_name(mclass);
            if isequal(sl,seg_length) && isequal(so,seg_overlap)
                load(fullfile(project_path,'segmentation',segs(i).name));
                % Check the classification
                [error,name,classifications] = check_classification(project_path,segmentation_configs,mclasses(j).name, 'WAITBAR',WAITBAR, 'DISPLAY', DISPLAY);
                if error
                    errordlg('Classification check failed','Error');
                    return
                end    
                % Generate the results
                for b = 1:length(b_pressed)
                    error = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed{b}, groups, 'WAITBAR',WAITBAR, 'DISPLAY', DISPLAY);
                    if error
                        errordlg('Cannot create results for strategies, transitions and probabilities','Error');
                        return
                    end
                    error = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed{b}, groups, 'DISTRIBUTION',2, 'EXTRA_NAME','_nosmooth', 'WAITBAR',WAITBAR, 'DISPLAY', DISPLAY);
                    if error
                        errordlg('Cannot create results for strategies, transitions and probabilities (smooth)','Error');
                        return
                    end                    
                end     
                % Statistics
                if STATISTICS
                    [error,~,~] = class_statistics(project_path, mclasses(j).name, 'WAITBAR', WAITBAR);
                    if error
                        errordlg('Error: statistics generation','Error');
                    end  
                    [error,~,~] = class_statistics(project_path, mclasses(j).name, 'SEGMENTATION', segmentation_configs, 'WAITBAR', WAITBAR, 'DISPLAY', DISPLAY);
                    if error
                        errordlg('Error: statistics generation (smooth)','Error');
                    end
                end
                break;
            end
        end
    end
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS (Classifiers)
    if PROBABILITIES
        b_pressed = {'Strategies','Transitions','Probabilities'};
    else
        b_pressed = {'Strategies','Transitions'};
    end
    segs = dir(fullfile(project_path,'segmentation','*.mat'));
    cclasses = dir(fullfile(project_path,'classification'));
    for i = 1:length(segs)
        seg = fullfile(project_path,'segmentation',segs(i).name);
        [~,~,sl,so] = split_segmentation_name(seg);
        if isequal(sl,'0') || isequal(so,'0')
            continue;
        end        
        for j = 3:length(cclasses)
            mclass = fullfile(project_path,'classification',cclasses(j).name);
            [~,~,~,seg_length,seg_overlap,~,~,~] = split_mclassification_name(mclass);
            if isequal(sl,seg_length) && isequal(so,seg_overlap)
                load(fullfile(project_path,'segmentation',segs(i).name));
                % Check the classification
                [error,name,classifications] = check_classification(project_path,segmentation_configs,cclasses(j).name, 'WAITBAR',WAITBAR, 'DISPLAY', DISPLAY);
                if error
                    errordlg('Classification check failed','Error');
                    return
                end    
                % Generate the results
                for b = 1:length(b_pressed)
                    error = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed{b}, groups, 'WAITBAR',WAITBAR, 'DISPLAY', DISPLAY);
                    if error
                        errordlg('Cannot create results for strategies, transitions and probabilities','Error');
                        return
                    end
                    error = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed{b}, groups, 'DISTRIBUTION',2, 'EXTRA_NAME','_nosmooth', 'WAITBAR',WAITBAR, 'DISPLAY', DISPLAY);
                    if error
                        errordlg('Cannot create results for strategies, transitions and probabilities (smooth)','Error');
                        return
                    end                    
                end     
                % Statistics
                if STATISTICS
                    [error,~,~] = class_statistics(project_path, cclasses(j).name, 'WAITBAR', WAITBAR);
                    if error
                        errordlg('Error: statistics generation','Error');
                    end  
                    [error,~,~] = class_statistics(project_path, cclasses(j).name, 'SEGMENTATION', segmentation_configs, 'WAITBAR', WAITBAR, 'DISPLAY', DISPLAY);
                    if error
                        errordlg('Error: statistics generation (smooth)','Error');
                    end
                end
                break;
            end
        end
    end
    
    %% Labelling Quality
    if LABELLING_QUALITY
        labs = dir(fullfile(project_path,'labels','*.mat'));
        segs = dir(fullfile(project_path,'segmentation','*.mat'));
        for i = 1:length(labs)
            [~,len,ovl,~,~] = split_labels_name(labs(i).name);
            if isequal(len,'0') || isequal(ovl,'0')
                continue
            end  
            p = strsplit(labs(i).name,'.mat');
            p = p{1};
            output_path = char(fullfile(project_path,'labels',strcat(p,'_check')));
            if ~exist(output_path,'dir')
                mkdir(output_path);
            end
            for s = 1:length(segs)
                seg = fullfile(project_path,'segmentation',segs(s).name);
                [~,~,sl,so] = split_segmentation_name(seg);
                if isequal(sl,len) && isequal(so,ovl)
                    load(fullfile(project_path,'segmentation',segs(s).name));
                    break;
                end 
            end
            mkdir(output_path);            
            [nc,res1bare,res2bare,res1,res2,res3,covering] = cross_validation(segmentation_configs,fullfile(project_path,'labels',labs(i).name),10,[10,100,10],output_path,'labels',0,'WAITBAR', WAITBAR, 'DISPLAY', DISPLAY);
            [nc,per_errors1,per_undefined1,coverage,per_errors1_true] = algorithm_statistics(1,1,nc,res1bare,res2bare,res1,res2,res3,covering);
            data = [nc', per_errors1', per_undefined1', coverage', per_errors1_true'];
            % export results to CSV file
            export_num_of_clusters(output_path,data);
            output_path = char(fullfile(project_path,'results',strcat(p,'_cross_validation')));
            if exist(output_path,'dir')
                rmdir(output_path,'s');
            end
            export_num_of_clusters(output_path,data);
            % generate graphs
            results_clustering_parameters_graphs(output_path,nc,res1bare,res2bare,res1,res2,res3,covering);
        end
    end
end

