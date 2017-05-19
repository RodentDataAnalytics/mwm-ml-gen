MERGE=1;
SIMPLE=1;
MMERGE=1;
N = 40;
DISTRIBUTION = 3;
input_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1'; 
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\test';
%load segmentation
load('D:\Avgoustinos\Documents\MWMGEN\Damien_train1\segmentation\segmentation_configs_9229_250_07.mat');
%load mclass of the best simple classifiers
load(fullfile(input_dir,'Mclassification','class_736_9229_250_07_40_1_mr0','merged_1.mat'));
ids = [5372,5272,5266,5172,5166,5072,5066,4972];
%mclass_f = {'class_736_9229_250_07_5_20_mr0'};
%mclass_f = {'class_736_9229_250_07_7_20_mr0'};
mclass_f = {'class_736_9229_250_07_5_25_mr0'};

% ARENA
load(fullfile(input_dir,'settings','new_properties.mat'));
R = new_properties{8};
intervals = [R/4,R/2,R,(3/2)*R,2*R];
sigma = intervals;
% SEGMENTATIONS
seg_files = dir(fullfile(input_dir,'segmentation','*.mat'));
segs = cell(1,length(seg_files));
for i = 1:length(seg_files)
    segs{i} = seg_files(i).name;
end
% CLASSIFICATIONS
class_folders = dir(fullfile(input_dir,'classification'));
class = cell(1,length(class_folders)-2);
k = 1;
for i = 3:length(class_folders)
    class{k} = class_folders(i).name;
    k = k+1;
end
files = dir(fullfile(input_dir,'classification',class{1},'*.mat'));
files = {files.name};
[num, idx] = sort_classifiers(files);
files = files(:,idx);
if N == 0
    N = length(files);
end
% MCLASSIFICATIONS
mclass_folders = dir(fullfile(input_dir,'Mclassification'));
mclass = cell(1,length(mclass_folders)-2);
k = 1;
for i = 3:length(mclass_folders)
    mclass{k} = mclass_folders(i).name;
    k = k+1;
end
% ANIMALS TRAJECTORIES MAPS
ATM = dir(fullfile(input_dir,'*.mat'));
Table = {};

%% MERGE 40 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if MERGE
for i = 1:length(ATM)-1
    load(fullfile(input_dir,ATM(i).name)); 
    tmp_Table = {};
    for j = 1:length(ids)
        tmp = animals_trajectories_map;
        tmp{1}(:,j) = [];
        p = results_strategies_distributions(segmentation_configs,classification_configs,tmp,0,output_dir,'DISTRIBUTION',DISTRIBUTION);
        for k = 1:length(p)
            tmp_Table{k,j} = p(k);
        end
    end
    Table = [Table;num2cell(ids);tmp_Table];
end
load(fullfile(input_dir,ATM(end).name));
tmp = animals_trajectories_map;
p = results_strategies_distributions(segmentation_configs,classification_configs,tmp,0,output_dir,'DISTRIBUTION',DISTRIBUTION);
for i = 1:length(p)
    Table{end+1,1} = p(i);
end
Table = cell2table(Table);
writetable(Table,fullfile(output_dir,'merge_40.csv'),'WriteVariableNames',0);
end

%% MERGE 40 SIMPLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if SIMPLE
for i = 1:length(ATM)-1
    load(fullfile(input_dir,ATM(i).name)); 
    f = fullfile(output_dir,ATM(i).name);
    mkdir(f);
    for j = 1:length(ids)
        tmp = animals_trajectories_map;
        tmp{1}(:,j) = [];
        f_ = fullfile(f,strcat('ex',num2str(ids(j))));
        mkdir(f_);
        %Friedman's test p-value (-1 if it is skipped)
        p_ = {};
        %Friedman's test sample data
        mfried_ = {};
        %Friedman's test num of replicates per cell
        nanimals_ = {};
        %Input data (vector)
        vals_ = {}; 
        %Grouping variable (length(x))
        vals_grps_ = {}; 
        %Position of each boxplot in the figure  tag a
        pos_ = {};          
        for jj = 1:N 
            load(fullfile(input_dir,'classification',class{1},files{jj}));
            [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classification_configs,tmp,0,f_,'DISTRIBUTION',DISTRIBUTION);
            p_{jj} = p;
            mfried_{jj} = mfried;
            nanimals_{jj} = nanimals;
            vals_{jj} = vals;
            vals_grps_{jj} = vals_grps;
            pos_{jj} = pos;     
        end
        total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
        class_tags = classification_configs.CLASSIFICATION_TAGS;
        create_average_figure(vals_,vals_grps_{1},pos_{1},f_,total_trials,class_tags); 
        create_pvalues_figure(p_,class_tags,f_);
        fpath = fullfile(f_,'pvalues_summary.csv');
        create_pvalues_table(p_,class_tags,fpath);        
    end
end
load(fullfile(input_dir,ATM(end).name));
tmp = animals_trajectories_map;
f = fullfile(output_dir,ATM(end).name);
mkdir(f);
%Friedman's test p-value (-1 if it is skipped)
p_ = {};
%Friedman's test sample data
mfried_ = {};
%Friedman's test num of replicates per cell
nanimals_ = {};
%Input data (vector)
vals_ = {}; 
%Grouping variable (length(x))
vals_grps_ = {}; 
%Position of each boxplot in the figure  tag a
pos_ = {};         
for jj = 1:N 
    load(fullfile(input_dir,'classification',class{1},files{jj}));
    [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classification_configs,tmp,0,f,'DISTRIBUTION',DISTRIBUTION);
    p_{jj} = p;
    mfried_{jj} = mfried;
    nanimals_{jj} = nanimals;
    vals_{jj} = vals;
    vals_grps_{jj} = vals_grps;
    pos_{jj} = pos;     
end
total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
class_tags = classification_configs.CLASSIFICATION_TAGS;
create_average_figure(vals_,vals_grps_{1},pos_{1},f,total_trials,class_tags); 
create_pvalues_figure(p_,class_tags,f);
fpath = fullfile(f,'pvalues_summary.csv');
create_pvalues_table(p_,class_tags,fpath);        
end

%% MERGE 40 SIMPLE; ITERATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if MMERGE
for mm = 1:length(mclass_f)
    mfiles = dir(fullfile(input_dir,'Mclassification',mclass_f{mm},'*.mat'));
    for i = 1:length(ATM)-1
        load(fullfile(input_dir,ATM(i).name)); 
        f = fullfile(output_dir,strcat('M',ATM(i).name));
        mkdir(f);
        for j = 1:length(ids)
            tmp = animals_trajectories_map;
            tmp{1}(:,j) = [];
            f_ = fullfile(f,strcat('ex',num2str(ids(j))));
            mkdir(f_);
            %Friedman's test p-value (-1 if it is skipped)
            p_ = {};
            %Friedman's test sample data
            mfried_ = {};
            %Friedman's test num of replicates per cell
            nanimals_ = {};
            %Input data (vector)
            vals_ = {}; 
            %Grouping variable (length(x))
            vals_grps_ = {}; 
            %Position of each boxplot in the figure  tag a
            pos_ = {};          
            for jj = 1:length(mfiles) 
                load(fullfile(input_dir,'Mclassification',mclass_f{mm},mfiles(jj).name));
                [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classification_configs,tmp,0,f_,'DISTRIBUTION',DISTRIBUTION);
                p_{jj} = p;
                mfried_{jj} = mfried;
                nanimals_{jj} = nanimals;
                vals_{jj} = vals;
                vals_grps_{jj} = vals_grps;
                pos_{jj} = pos;     
            end
            total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
            class_tags = classification_configs.CLASSIFICATION_TAGS;
            create_average_figure(vals_,vals_grps_{1},pos_{1},f_,total_trials,class_tags); 
            create_pvalues_figure(p_,class_tags,f_);
            fpath = fullfile(f_,'pvalues_summary.csv');
            create_pvalues_table(p_,class_tags,fpath);        
        end
    end
    load(fullfile(input_dir,ATM(end).name));
    tmp = animals_trajectories_map;
    f = fullfile(output_dir,strcat('M',ATM(end).name));
    mkdir(f);
    %Friedman's test p-value (-1 if it is skipped)
    p_ = {};
    %Friedman's test sample data
    mfried_ = {};
    %Friedman's test num of replicates per cell
    nanimals_ = {};
    %Input data (vector)
    vals_ = {}; 
    %Grouping variable (length(x))
    vals_grps_ = {}; 
    %Position of each boxplot in the figure  tag a
    pos_ = {};         
    for jj = 1:length(mfiles) 
        load(fullfile(input_dir,'Mclassification',mclass_f{mm},mfiles(jj).name));
        [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classification_configs,tmp,0,f,'DISTRIBUTION',DISTRIBUTION);
        p_{jj} = p;
        mfried_{jj} = mfried;
        nanimals_{jj} = nanimals;
        vals_{jj} = vals;
        vals_grps_{jj} = vals_grps;
        pos_{jj} = pos;     
    end
    total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
    class_tags = classification_configs.CLASSIFICATION_TAGS;
    create_average_figure(vals_,vals_grps_{1},pos_{1},f,total_trials,class_tags); 
    create_pvalues_figure(p_,class_tags,f);
    fpath = fullfile(f,'pvalues_summary.csv');
    create_pvalues_table(p_,class_tags,fpath);           
end    
end