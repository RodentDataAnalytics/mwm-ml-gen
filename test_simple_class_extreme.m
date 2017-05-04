run = 1;
DISTRIBUTION = 3;

if run == 1
    R = 100;
    input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
    output_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data\results\test';
    f_output = output_dir;
    str_seg = {'segmentation_configs_8447_300_07.mat',...
               'segmentation_configs_10388_250_07.mat',...
               'segmentation_configs_29476_250_09.mat',...
               'segmentation_configs_13283_200_07.mat',...
               'segmentation_configs_13283_200_07.mat'};
    str_class = {'class_989_8447_300_07',...
                'class_1301_10388_250_07',...
                'class_2445_29476_250_09',...
                'class_995_13283_200_07',...
                'class_1050_13283_200_07'};
elseif run == 2
    R = 75;
    input_dir = 'D:\Avgoustinos\Documents\MWMGEN\Artur_exp1_sameplat';
    output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Artur_exp1_sameplat\results\test';  
    f_output = output_dir;
    str_seg = {'segmentation_configs_3736_200_07.mat','segmentation_configs_3736_200_07.mat','segmentation_configs_5261_150_07.mat','segmentation_configs_11881_180_09.mat','segmentation_configs_11881_180_09.mat'};    
    str_class = {'class_280_3736_200_07','class_310_3736_200_07','class_532_5261_150_07','class_831_11881_180_09','class_855_11881_180_09'}; 
end
load(fullfile(input_dir,'animals_trajectories_map.mat'));

intervals = [R/4,R/2,R,(3/2)*R,2*R];
sigma = intervals;

for il = 1:length(intervals)%INTERVAL
for s = 1:length(sigma) %SIGMA  
    fprintf('interval=%d,sigma=%d\n',intervals(il),sigma(s))
    str_dir = strcat('interval_',num2str(intervals(il)),'_sigma_',num2str(sigma(s)));
    output_dir = fullfile(f_output,'extreme',str_dir);
    if ~exist(output_dir,'dir')
        mkdir(output_dir);
    end
    
for i = 1:length(str_seg)
    % delete previous and make new output subfolder
    output_path = fullfile(output_dir,str_class{i});
    if exist(output_path,'dir')
        tmp = fopen('all');
        for t = 1:length(tmp)
            fclose(tmp(t));
        end
        rmdir(output_path,'s');
    end
    mkdir(output_path);
    
    % load the files and make folder tree
    load(fullfile(input_dir,'segmentation',str_seg{i}));
    input_path = fullfile(input_dir,'classification',str_class{i});
    files = dir(fullfile(input_path,'*.mat'));
    files = {files.name};
    [num, idx] = sort_classifiers(files);
    files = files(:,idx);
    N = length(files);
    classifications = cell(1,N);
    dir_list = cell(1,N+1);
    dir_list_tr = cell(1,N+1);
    for j = 1:N
        clear classification_configs;
        load(fullfile(input_dir,'classification',str_class{i},files{j}));
        classifications{j} = classification_configs;
        tmp = strsplit(files{j},{'classification_configs_','.mat'});
        dir_list{j} = fullfile(output_path,tmp{2});
        mkdir(dir_list{j});
        dir_list_tr{j} = fullfile(output_path,tmp{2},'transitions');
        mkdir(dir_list_tr{j});
    end
    dir_list{end} = fullfile(output_path,'summary');
    mkdir(dir_list{end});
    dir_list_tr{end} = fullfile(output_path,'summary','transitions');
    mkdir(dir_list_tr{end});
   
    % Variables of interest:
    %Friedman's test p-value (-1 if it is skipped)
    p_ = cell(1,length(classifications));
    p_trial = cell(1,length(classifications));
    %Friedman's test sample data
    mfried_ = cell(1,length(classifications));
    %Friedman's test num of replicates per cell
    nanimals_ = cell(1,length(classifications));
    %Input data (vector)
    vals_ = cell(1,length(classifications)); 
    %Grouping variable (length(x))
    vals_grps_ = cell(1,length(classifications)); 
    %Position of each boxplot in the figure  
    pos_ = cell(1,length(classifications));     
    
    %h = waitbar(0,'Generating results...','Name','Strategies');
    for j = 1:N  
        [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classifications{j},animals_trajectories_map,0,dir_list{j},'DISTRIBUTION',DISTRIBUTION,'INTERVAL',intervals(il),'SIGMA',sigma(s));
        %p_t = results_avg_strategies_trial(segmentation_configs,classifications{j},mfried,nanimals,dir_list{j});
        %p_trial{j} = p_t;
        p_{j} = p;
        mfried_{j} = mfried;
        nanimals_{j} = nanimals;
        vals_{j} = vals;
        vals_grps_{j} = vals_grps;
        pos_{j} = pos;
        %waitbar(j/length(classifications)); 
    end
    
    %waitbar(1,h,'Finalizing...');
    save(fullfile(output_path,'values.mat'),'p_','mfried_','nanimals_','vals_','vals_grps_','pos_');
    total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
    class_tags = classifications{1}.CLASSIFICATION_TAGS;
    create_average_figure(vals_,vals_grps_{1},pos_{1},dir_list{end},total_trials,class_tags); 

    error = create_pvalues_figure(p_,class_tags,dir_list{end});
    %error = create_pvalues_figure(p_trial,class_tags,dir_list{end},'trial',1);
    
    fpath = fullfile(dir_list{end},'pvalues_summary.csv');
    error = create_pvalues_table(p_,class_tags,fpath);
    %fpath = fullfile(dir_list{end},'pvalues_trial_summary.csv');
    %error = create_pvalues_table(p_trial,class_tags,fpath,'trial',1);
    
    %delete(h);
    
    %% Transitions
    
    % Variables of interest:
    %Friedman's test p-value (-1 if it is skipped)
    p_ = cell(1,length(classifications));
    p_trial = cell(1,length(classifications));
    %Friedman's test sample data
    mfried_ = cell(1,length(classifications));
    %Friedman's test num of replicates per cell
    nanimals_ = cell(1,length(classifications));
    %Input data (vector)
    vals_ = cell(1,length(classifications)); 
    %Grouping variable (length(x))
    vals_grps_ = cell(1,length(classifications)); 
    %Position of each boxplot in the figure  
    pos_ = cell(1,length(classifications));   
    
    %h = waitbar(0,'Generating results...','Name','Transitions');
    for j = 1:N  
        [p,mfried,nanimals,vals,vals_grps,pos] = results_transition_counts(segmentation_configs,classifications{j},animals_trajectories_map,0,dir_list_tr{j},'DISTRIBUTION',DISTRIBUTION,'INTERVAL',intervals(il),'SIGMA',sigma(s));
        %p_t = results_avg_strategies_trial(segmentation_configs,classifications{j},mfried,nanimals,dir_list{j});
        %p_trial{j} = p_t;
        p_{j} = p;
        mfried_{j} = mfried;
        nanimals_{j} = nanimals;
        vals_{j} = vals;
        vals_grps_{j} = vals_grps;
        pos_{j} = pos;
        %waitbar(j/length(classifications)); 
    end
    
    %waitbar(1,h,'Finalizing...');
    save(fullfile(output_path,'transitions.mat'),'p_','mfried_','nanimals_','vals_','vals_grps_','pos_');
    total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
    class_tags = {{'Transitions','Transitions',0,0}};
    create_average_figure(vals_,vals_grps_,pos_,dir_list_tr{end},total_trials,class_tags);

    error = create_pvalues_figure(p_,class_tags,dir_list_tr{end},'tag',{''},'xlabel','transitions');
    
    fpath = fullfile(dir_list_tr{end},'transitions_summary.csv');
    error = create_pvalues_table(p_,class_tags,fpath);

    %delete(h);
end

end
end