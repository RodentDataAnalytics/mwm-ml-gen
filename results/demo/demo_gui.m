function demo_gui(set,user_path,varargin)
%DEMO_GUI executes the processes: segmentation, labelling, classification
%and produces the results

    %%Global Options
    if set == 1
        seg_overlap = [0.7,0.9];
        seg_length = 250;
        groups = [1,2];
        if ~isempty(varargin)
            if varargin{1} == -1
                seg_overlap = 0.7;
            end
        end
    elseif set == 2
    end
        
    
    user_path = char_project_path(user_path);
    h = waitbar(0,'Initializing...');
    
    %% Create project folder tree (set_folder.m)
    if set == 1
        error = build_folder_tree(user_path, 'demo_original_set_1');
    elseif set == 2
        error = build_folder_tree(user_path, 'demo_original_set_2');
    end
    if error
        return
    end
    
    if set == 1
        project_path = fullfile(user_path,'demo_original_set_1');
    elseif set == 2
        project_path = fullfile(user_path,'demo_original_set_2');
    end
    waitbar(1/2);
    
    %% Copy the settings mat files (skip gui_project.m)
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
    waitbar(2/2);
    delete(h);
    
    %% Segmentation
    try
        load(fullfile(project_path,'settings','new_properties.mat'));
        load(fullfile(project_path,'settings','animal_groups.mat'));
        load(fullfile(project_path,'settings','my_trajectories.mat'));
    catch
        errordlg('Cannot load project settings','Error');
        return
    end

    for i = 1:length(seg_overlap)
        seg_properties = [seg_length,seg_overlap(i)];
        segmentation_configs = config_segments(new_properties, seg_properties, trajectory_groups, my_trajectories);
        save_segmentation(segmentation_configs, project_path);
    end    
    
    %% Labelling
    files = dir(fullfile(datapath,'*.csv'));
    seg_name = dir(fullfile(project_path,'segmentation','*.mat'));
    for i = 1:length(seg_overlap)
        %copy the csv files from the datapath
        labels_path = fullfile(datapath,files(i).name);
        copyfile(labels_path,fullfile(project_path,'labels'));
        %the labels are now inside the project path
        labels_path = fullfile(project_path,'labels',files(i).name);
        %load the segmentation and generate the labels mat file
        load(fullfile(project_path,'segmentation',seg_name(i).name));
        generate_mat_from_labels(labels_path,segmentation_configs);
        clear segmentation_configs
    end
    
    %% Classification
    lab_name = dir(fullfile(project_path,'labels','*.mat'));
    for i = 1:length(seg_overlap)
        %check if everything is ok
        if ~exist(fullfile(project_path,'labels',lab_name(i).name),'file')
            errordlg('Cannot create classifiers','Error');
            return
        end        
        default_classification(project_path,seg_name(i).name,lab_name(i).name);
    end
    
    %% Animal Trajectories Map
    load(fullfile(project_path,'segmentation',seg_name(1).name));
    [exit, animals_trajectories_map] = trajectories_map(segmentation_configs,groups,'Friedman',set);
    
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
        results_latency_speed_length(segmentation_configs,animals_trajectories_map,1,output_dir);
    catch
        errordlg('Error: metrics generation','Error');
    end
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS
    b_pressed = {'Strategies','Transitions','Probabilities'};
    class = dir(fullfile(project_path,'Mclassification'));
    
    for j = 1:length(seg_overlap)
		load(fullfile(project_path,'segmentation',seg_name(i).name));

        % Check the classification
        [error,name,classifications] = check_classification(project_path,segmentation_configs,class(2+j).name);
        if error
            errordlg('Classification check failed','Error');
            return
        end
        
        % Generate the results
        for i = 1:length(b_pressed)
            error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed{i}, groups);
            if error
                errordlg('Cannot create results for strategies, transitions and probabilities','Error');
                return
            end
        end
        
        % Statistics
        [error,~,~] = class_statistics(project_path, class(2+j).name);
        if error
            errordlg('Error: statistics generation','Error');
        end   
    end
    
    %% Labelling Quality
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

