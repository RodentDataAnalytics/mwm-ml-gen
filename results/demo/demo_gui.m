function demo_gui(set,user_path)
%DEMO_GUI executes the processes: segmentation, labelling, classification
%and produces the results

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
    project_path = fullfile(user_path,'demo_original_set_1');
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
    seg_overlap = [0.7,0.9];
    seg_length = 250;
    for i = 1:length(seg_overlap)
        seg_properties = [seg_length,seg_overlap(i)];
        segmentation_configs = config_segments(new_properties, seg_properties, trajectory_groups, my_trajectories);
        save_segmentation(segmentation_configs, project_path);
    end    
    
    %% Labelling
    files = {'labels_1301_250_07-tiago.csv','labels_1657_250_09-tiago.csv'};
    seg_name = {'segmentation_configs_10388_250_07.mat','segmentation_configs_29476_250_09.mat'};
    for i = 1:2
        %check if everything is ok
        if ~exist(fullfile(datapath,files{i}),'file') || ~exist(fullfile(project_path,'segmentation',seg_name{i}),'file')
            errordlg('Cannot create labels files','Error');
            return
        end
        %copy the csv files from the datapath
        labels_path = fullfile(datapath,files{i});
        copyfile(labels_path,fullfile(project_path,'labels'));
        %the labels are now inside the project path
        labels_path = fullfile(project_path,'labels',files{i});
        %load the segmentation and generate the labels mat file
        load(fullfile(project_path,'segmentation',seg_name{i}));
        generate_mat_from_labels(labels_path,segmentation_configs);
        clear segmentation_configs
    end
    
    %% Classification
    lab_name = {'labels_1301_250_07-tiago.mat','labels_1657_250_09-tiago.mat'};
    for i = 1:length(seg_name)
        %check if everything is ok
        if ~exist(fullfile(project_path,'labels',lab_name{i}),'file')
            errordlg('Cannot create classifiers','Error');
            return
        end        
        default_classification(project_path,seg_name{i},lab_name{i});
    end    
    
    %% Results
    groups = [1,2];
    load(fullfile(project_path,'segmentation',seg_name{1}));
    [exit, animals_trajectories_map] = trajectories_map(segmentation_configs,groups,'Friedman',set);
    
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
    class = {'class_1301_10388_250_07_10_10_mr0-tiago','class_1657_29476_250_09_10_10_mr0-tiago'};
    for j = 1:length(seg_name)
        
        % Check if everything is ok
        if ~exist(fullfile(project_path,'Mclassification',class{j}),'file')
            errordlg('Check fail for results: strategies, transitions and probabilities','Error');
            return
        end     
        
        % Statistics
        [error,~,~] = class_statistics(project_path, class{j});
        if error
            errordlg('Error: statistics generation','Error');
        end   
    
        % Check the classification
        [error,name,classifications] = check_classification(project_path,segmentation_configs,class{j});
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
    end
    
    %% Labelling Quality
    files = {'labels_1301_250_07-tiago.mat','labels_1657_250_09-tiago.mat'};
    for i = 1:2
        load(fullfile(project_path,'segmentation',seg_name{i}));
        load(fullfile(project_path,'labels',files{i}));
        
        p = strsplit(files{i},'.mat');
        p = p{1};
        output_path = char(fullfile(project_path,'labels',strcat(p,'_check')));
        if ~exist(output_path,'dir')
            mkdir(output_path);
        end
        [nc,res1bare,res2bare,res1,res2,res3,covering] = results_clustering_parameters(segmentation_configs,labels,0,output_path,10,100,1);
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

