%% Options

%input_dir = uigetdir('','Specify project folder');
%output_dir = uigetdir('','Specify output folder');
input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
output_dir = 'D:\Program Test';

segs = {'segmentation_configs_8447_300_07.mat',...
        'segmentation_configs_10388_250_07.mat',...
        'segmentation_configs_29476_250_09.mat',...
        'segmentation_configs_13283_200_07.mat'};
 
% classifs = {'class_989_8447_300_07_111_1_mr0',...
%             'class_1301_10388_250_07_111_1_mr0',...
%             'class_2447_29476_250_09_111_1_mr0',...
%             'class_995_13283_200_07_111_1_mr0'};
        
classifs = {'class_989_8447_300_07_21_1_mr0',...
            'class_1301_10388_250_07_21_1_mr0',...
            'class_2447_29476_250_09_21_1_mr0',...
            'class_995_13283_200_07_21_1_mr0'};        

%% Initialization
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
load(fullfile(input_dir,'animals_trajectories_map.mat'));
seg_path = fullfile(input_dir,'segmentation');
class_path = fullfile(input_dir,'Mclassification');
ext = 'merged_1.mat';
figures = 0;
store = cell(1,4);
table_tmp = [];
for i = 1:4
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath);
    load(cpath);
    %results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    p_table1 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    p_table2 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    temp = [p_table1 ; p_table2];
    table_tmp = [table_tmp , temp];
end

labels = {};
for i = 1:length(classification_configs.CLASSIFICATION_TAGS)
    labels{i,1} = classification_configs.CLASSIFICATION_TAGS{i}{2};
end
labels{end+1,1} = 'tr';
table_tmp = num2cell(table_tmp);
table_tmp = [labels,table_tmp];

table = cell2table(table_tmp,'VariableNames',{'CLASS','L300V70','L250V70','L250V90','L200V70'});
writetable(table,fullfile(output_dir,'results.csv'),'WriteVariableNames',1);
