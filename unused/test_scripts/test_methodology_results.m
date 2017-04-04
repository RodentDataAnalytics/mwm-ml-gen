% This script generates the results of for each 111 classification 

input_dir = uigetdir;
output_dir = uigetdir;

load(fullfile(input_dir,'animals_trajectories_map.mat'));

seg_path = fullfile(input_dir,'segmentation');
segs = {'segmentation_configs_8447_300_07.mat',...
        'segmentation_configs_10388_250_07.mat',...
        'segmentation_configs_29476_250_09.mat',...
        'segmentation_configs_13283_200_07.mat'};
    
class_path = fullfile(input_dir,'Mclassification');
ext = 'merged_1.mat';
% classifs = {'class_989_8447_300_07_111_1_mr0',...
%             'class_1301_10388_250_07_111_1_mr0',...
%             'class_2447_29476_250_09_111_1_mr0',...
%             'class_995_13283_200_07_111_1_mr0'};

classifs = {'class_989_8447_300_07_21_1_mr0',...
            'class_1301_10388_250_07_21_1_mr0',...
            'class_2447_29476_250_09_21_1_mr0',...
            'class_995_13283_200_07_21_1_mr0'};
        
figures = 0;

for k = 1:3
    if k == 1
        ones = 1;
        bounds = 0;
        fprintf('\n<<WEIGHTS ONES>>\n');
    elseif k == 2
        ones = 0;
        bounds = 0;
        fprintf('\n<<WEIGHTS UNBOUNDED>>\n');
    elseif k == 3
        ones = 0;
        bounds = 1;
        fprintf('\n<<WEIGHTS BOUNDED>>\n');
    end
    for i = 1:4
        spath = fullfile(seg_path,segs{i});
        cpath = fullfile(class_path,classifs{i},ext);
        load(spath)
        load(cpath)
        fprintf(strcat('\n',segs{i},'\n'));
        p_table = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'WEIGHTS_ONES',ones,'HARD_BOUNDS',bounds);
        %p_tr = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
        fprintf('\n...\n');
    end    
end 


for z = 1:2
    if z == 1
        DIVIDE = 0;
        fprintf('\n<<DIVIDE OFF>>\n');
    elseif z == 2
        DIVIDE = 1;
        fprintf('\n<<DIVIDE ON>>\n');
    end
    
    for k = 1:3
        if k == 1
            ones = 1;
            bounds = 0;
            fprintf('\n<<WEIGHTS ONES>>\n');
        elseif k == 2
            ones = 0;
            bounds = 0;
            fprintf('\n<<WEIGHTS UNBOUNDED>>\n');
        elseif k == 3
            ones = 0;
            bounds = 1;
            fprintf('\n<<WEIGHTS BOUNDED>>\n');
        end    
        
        for i = 1:4
            spath = fullfile(seg_path,segs{i});
            cpath = fullfile(class_path,classifs{i},ext);
            load(spath)
            load(cpath)
            fprintf(strcat('\n',segs{i},'\n'));
            p_tr = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'DIVIDE',DIVIDE,'WEIGHTS_ONES',ones,'HARD_BOUNDS',bounds);
            fprintf('\n...\n');
        end    
    end
end 