project_path = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1';
load('D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1\classification\class_989_8447_300_07\classification_configs_8447_989_10.mat');

scenarios = {'main','pool_size_40','sample_5','ensembles_13','merge_all'};
ttitle = {'Segmentation IV','Segmentation II','Segmentation III','Segmentation I'};

WAITBAR = 0;
DISPLAY = 0;
groups = [1,2];
STATISTICS = 1;

load(fullfile(project_path,'settings','new_properties.mat'));
load(fullfile(project_path,'settings','animal_groups.mat'));
load(fullfile(project_path,'settings','my_trajectories.mat'));
load(fullfile(project_path,'settings','my_trajectories_features.mat'));

class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};

%% Mclassification
for S = 1:length(scenarios)
    switch S
        case 1 %original
            %Mclusters = {10:58, 10:80, 10:99, 10:58};
            Mclusters = {[10:58,61:73,82:85,90,92], [10:80,83,86], 10:99, [10:58,61:67,70:73,79,83,85]};
            sample = 11;
            iterations = 21;   
        case 2 %pool 40
            Mclusters = {10:49, 10:49, 10:49, 10:49};
            sample = 11;
            iterations = 21;   
        case 3 %sample 5
            Mclusters = {10:58, 10:80, 10:99, 10:58};
            sample = 5;
            iterations = 21;    
        case 4 %ensembles 13
            Mclusters = {10:58, 10:80, 10:99, 10:58};
            sample = 11;
            iterations = 13;  
        case 5 %merge all
            %Mclusters = {10:58, 10:80, 10:99, 10:58};
            Mclusters = {[10:58,61:73,82:85,90,92], [10:80,83,86], 10:99, [10:58,61:67,70:73,79,83,85]};
            %sample = {49,71,90,49};
            sample = {68,73,90,63};
            iterations = 1;    
    end
    %% MCLASSIFICATION
    classifs = dir(fullfile(project_path,'classification'));
    %order: {'class_1049_13283_200_07';'class_1301_10388_250_07';'class_2445_29476_250_09';'class_989_8447_300_07'}
    for i = 3:length(classifs)
        if iscell(sample)
            execute_Mclassification(project_path, {classifs(i).name}, sample{i-2}, iterations, 0, 'CLUSTERS', Mclusters{i-2}, 'WAITBAR',0);
        else
            execute_Mclassification(project_path, {classifs(i).name}, sample, iterations, 0, 'CLUSTERS', Mclusters{i-2}, 'WAITBAR',0);
        end
    end
    %% RESULTS
    % Animal Trajectories Map
    [~, animals_trajectories_map] = trajectories_map(my_trajectories,my_trajectories_features,groups,'Friedman',1);
    
    % STRATEGIES - TRANSITIONS - PROBABILITIES - STATISTICS
    b_pressed = {'Strategies','Transitions'};

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
                [error,~,~] = class_statistics(project_path, mclasses(j).name, 'SEGMENTATION', segmentation_configs);
                if error
                    errordlg('Error: statistics generation','Error');
                end  
                %break;
            end
        end
    end
    
    %% Create another folder and copy there everything in subfolders
    npath = fullfile(project_path,'paper_results');
    if ~exist(npath,'dir')
        mkdir(fullfile(project_path,'paper_results'));
    end
    npath = fullfile(project_path,'paper_results',scenarios{S});
    if ~exist(npath,'dir')
        mkdir(fullfile(project_path,'paper_results',scenarios{S}));
    end
    copyfile(fullfile(fullfile(project_path,'results')), fullfile(project_path,'paper_results',scenarios{S}));

    %% Collect the results
    folders = dir(fullfile(project_path,'results'));
    if S ~= 5
        t1 = zeros(8,4);
        t1i = 1;
        t2 = zeros(1,4); 
        t2i = 1;
        for f = 3:length(folders)
            tmp = strfind(folders(f).name,'Strategies');
            if isempty(tmp)
                tmp = strfind(folders(f).name,'Transitions');
                if isempty(tmp)
                    continue
                else
                    fid = fopen(fullfile(project_path,'results',folders(f).name,'g12res_summary','pvalues_summary.csv'));
                    a=fgetl(fid);
                    a=fgetl(fid);
                    a=strsplit(a,',');
                    a=str2num(a{2});
                    t2(t2i) = a;                   
                end
                t2i = t2i+1;
            else
                fid = fopen(fullfile(project_path,'results',folders(f).name,'g12res_summary','pvalues_summary.csv'));
                a=fgetl(fid);
                for l = 1:8
                    a=fgetl(fid);
                    a=strsplit(a,',');
                    a=str2num(a{2});
                    t1(l,t1i) = a;
                end
                t1i = t1i+1;
            end
        end
        t = [t1;t2];
        fpath = fullfile(project_path,'paper_results',scenarios{S});
        save(fullfile(fpath,'res'),'t');
        for iter = 1:size(t,2)
            paper_fig_confidence_intervals(t(:,iter)',iterations,class_tags,fpath,iter,ttitle{iter});
        end
    end
    
    %% Delete and recrate 'Mclassification' and 'results' folders
    fclose('all');
    rmdir(fullfile(project_path,'Mclassification'),'s');
    rmdir(fullfile(project_path,'results'),'s');
    mkdir(fullfile(project_path,'Mclassification'));
    mkdir(fullfile(project_path,'results'));
end