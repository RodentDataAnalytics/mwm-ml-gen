MClassifiers_folder = 'I:\Documents\MWMGEN\Test\split_10';
Output_folder = 'I:\Documents\MWMGEN\Test';
Segmentation = 'I:\Documents\MWMGEN\tiago_original\segmentation\segmentation_configs_29476_250_09.mat';
Name = 'Strategies_1664_250_09';

load(Segmentation);

% Construct the trajectories_map and equalize the groups
groups = [1,2];
[exit, animals_trajectories_map] = trajectories_map(segmentation_configs,groups,'Friedman',1);
if exit
    errordlg('Error: animals_trajectories_map');
    return
end

% Folders & Classifications
h = waitbar(0,'Folders & Classifications','Name','Results');
files = dir(fullfile(MClassifiers_folder,'*.mat'));
classifications = {};
dir_list = {};
for i = 1:length(files)
    class = fullfile(MClassifiers_folder,files(i).name);
    load(class)
    classifications{i} = classification_configs;
    folder = fullfile(Output_folder,Name,strcat('merged_',num2str(i)));
    if ~exist(folder,'dir')
        mkdir(folder);
    end
    dir_list{i} = folder;
    waitbar(i/length(files)); 
end
folder = fullfile(Output_folder,Name,'summary');
mkdir(folder);
dir_list{end+1} = folder;
delete(h)

%% Results

% Variables of interest:
%Friedman's test p-value (-1 if it is skipped)
p_ = cell(1,length(classifications));
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

for i = 1:length(classifications)
    [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions_length(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
    p_{i} = p;
    mfried_{i} = mfried;
    nanimals_{i} = nanimals;
    vals_{i} = vals;
    vals_grps_{i} = vals_grps;
    pos_{i} = pos;
    waitbar(i/length(classifications)); 
end
waitbar(1,h,'Finalizing...');
total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
class_tags = classifications{1}.CLASSIFICATION_TAGS;
create_average_figure(vals_,vals_grps_{1},pos_{1},dir_list{end},total_trials,class_tags);
fpath = fullfile(dir_list{end},'pvalues_summary.csv');
error = create_pvalues_table(p_,class_tags,fpath);
delete(h);