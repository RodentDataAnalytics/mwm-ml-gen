%% Options

%input_dir = uigetdir('','Specify project folder');
%output_dir = uigetdir('','Specify output folder');
input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
output_dir = 'C:\Users\Avgoustinos\Desktop\test_results\test_results';

segs = {'segmentation_configs_8447_300_07.mat',...
        'segmentation_configs_10388_250_07.mat',...
        'segmentation_configs_29476_250_09.mat',...
        'segmentation_configs_13283_200_07.mat'};
 
classifs = {'class_989_8447_300_07_111_1_mr0',...
            'class_1301_10388_250_07_111_1_mr0',...
            'class_2447_29476_250_09_111_1_mr0',...
            'class_995_13283_200_07_111_1_mr0'};
        
% classifs = {'class_989_8447_300_07_21_1_mr0',...
%             'class_1301_10388_250_07_21_1_mr0',...
%             'class_2447_29476_250_09_21_1_mr0',...
%             'class_995_13283_200_07_21_1_mr0'};        

%% Initialization
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
load(fullfile(input_dir,'animals_trajectories_map.mat'));
seg_path = fullfile(input_dir,'segmentation');
class_path = fullfile(input_dir,'Mclassification');
ext = 'merged_1.mat';
figures = 0;
store = cell(1,4);

% Make the output folder tree
folder = fullfile(output_dir,'test');
if exist(folder,'dir')
    rmdir(folder,'s');
end
mkdir(folder);
npath = fullfile(output_dir,'test');
str = {'default_values.txt','unbounded_weights.txt','weights_ones.txt','classification_results.txt'};

%% Scripts
default_results;
use_class_results;
unbounded_weigths;
ones_weights;
%plot_weights_figures;
plot_results_per_method;
plot_results_per_segmentation;
