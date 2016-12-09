segmentation_path = 'C:\Users\Avgoustinos\Documents\MWMGEN\demo_original_set_1\segmentation\segmentation_configs_10388_250_07.mat';
classification_folder = 'C:\Users\Avgoustinos\Documents\MWMGEN\demo_original_set_1\Mclassification\class_1301_10388_250_07_10_10_mr0-tiago';
animals_trajectories_map_file = 'C:\Users\Avgoustinos\Desktop\original_data\traj_map.mat';

% Output Folder
output_folder = char(getSpecialFolder('Desktop'));
output_folder = fullfile(output_folder,'test_sigma');
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

load(segmentation_path);
load(animals_trajectories_map_file);
mclass = dir(fullfile(classification_folder,'*.mat'));
% For every mergeX.mat
for i = 1:length(mclass)
    class_path = fullfile(classification_folder,mclass(i).name);
    load(class_path);
    %make new dir for the distr_strat files
    distr_strat_folder = fullfile(output_folder,strcat('merge_distr',num2str(i)));
    if ~exist(distr_strat_folder,'dir')
        mkdir(distr_strat_folder);
    end
    %generate 50 distr_strat with sigma = 1:50
    test_sigma_distr_strat(segmentation_configs,classification_configs,distr_strat_folder);
    files = dir(fullfile(distr_strat_folder,'*.mat'));
    results_dir = fullfile(output_folder,strcat('merge_res',num2str(i)));
    if ~exist(results_dir,'dir')
        mkdir(results_dir);
    end    
    %run results_strategies_distributions_length 50 times
    h = waitbar(0,'Generating results');
    for j = 1:length(files)
        load(fullfile(distr_strat_folder,files(j).name));
        s_results_dir = fullfile(results_dir,strcat('merge_',num2str(j)));
        mkdir(s_results_dir);
        test_sigma_results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,0,s_results_dir,strat_distr);
        waitbar(j/length(files));
    end
    delete(h);
    %collect info from the txt files
    txtfolders = dir(results_dir);
    all_nums = [];
    for zz = 3:length(txtfolders)
        file = dir(fullfile(results_dir,txtfolders(zz).name,'*.txt'));
        file_p = fullfile(results_dir,txtfolders(zz).name,file.name);
        fid = fopen(file_p);
        C = textscan(fid, '%s','delimiter', '\n');
        fclose(fid);
        C = C{1};
        nums = [];
        for j = 1:length(C)
            num = strsplit(C{j},':');
            num = str2double(num(end));
            nums = [nums;num];
        end
        all_nums = [all_nums,nums];
    end
    %save to csv file
    name = strcat('final',num2str(i),'.csv');
    full_path = fullfile(output_folder,name);
    all_nums = num2cell(all_nums);
    tags = {'TT';'IC';'SC';'FS';'CR';'SO';'SS';'ST'};
    all_nums = [tags,all_nums];
    numbers = [];
    for fix = 1:length(files)
        number = files(fix).name;
        number = strsplit(number,{'strat_distr','.mat'});
        number = str2double(number{2});
        numbers = [numbers,number];
    end
    numbers = num2cell(numbers);
    all_nums = ['.',numbers;all_nums];
    all_nums = cell2table(all_nums);
    writetable(all_nums,full_path,'WriteVariableNames',0);
end