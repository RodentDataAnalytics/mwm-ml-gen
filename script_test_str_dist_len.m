output_dir = 'C:\Users\Avgoustinos\Desktop\New folder (3)';
figures = 0;
load('C:\Users\Avgoustinos\Desktop\animals_trajectories_map.mat')

seg_path = 'C:\Users\Avgoustinos\Documents\MWMGEN\EPFL_original_data\segmentation';
segs = {'segmentation_configs_8447_300_07.mat',...
        'segmentation_configs_10388_250_07.mat',...
        'segmentation_configs_29476_250_09.mat',...
        'segmentation_configs_13283_200_07.mat'};
    
class_path = 'C:\Users\Avgoustinos\Documents\MWMGEN\EPFL_original_data\Mclassification';
ext = 'merged_1.mat';
classifs = {'class_989_8447_300_07_111_1_mr0',...
            'class_1301_10388_250_07_111_1_mr0',...
            'class_2447_29476_250_09_111_1_mr0',...
            'class_995_13283_200_07_111_1_mr0'};
        
for i = 1:4
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath)
    load(cpath)
    fprintf(strcat('\n',segs{i},'\n'));
    p_table = results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    p_tr = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    fprintf('\n==================\n')
end