%% Options

%input_dir = uigetdir('','Specify project folder');
%output_dir = uigetdir('','Specify output folder');
run = 2;
output_dir = 'D:\Program Test';

if run == 1
    input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
    segs = {'segmentation_configs_8447_300_07.mat',...
            'segmentation_configs_10388_250_07.mat',...
            'segmentation_configs_29476_250_09.mat',...
            'segmentation_configs_13283_200_07.mat',...
            'segmentation_configs_13283_200_07.mat'}; 
%     classifs = {'class_989_8447_300_07_111_1_mr0',...
%                 'class_1301_10388_250_07_111_1_mr0',...
%                 'class_2445_29476_250_09_111_1_mr0',...
%                 'class_995_13283_200_07_111_1_mr0'};     
    classifs = {'class_989_8447_300_07_50_1_mr0',...
                'class_1301_10388_250_07_50_1_mr0',...
                'class_2445_29476_250_09_50_1_mr0',...
                'class_995_13283_200_07_40_1_mr0',...
                'class_1050_13283_200_07_40_1_mr0'};      
    head = {'CLASS','L300V70','L250V70','L250V90','L200V70','P20070MORE'};
    R = 100;
    intervals = [R/4,R/2,R,(3/2)*R,2*R];
elseif run == 2   
    input_dir = 'D:\Avgoustinos\Documents\MWMGEN\Artur_exp1_sameplat';
    %segs = {'segmentation_configs_5261_150_07.mat','segmentation_configs_3736_200_07','segmentation_configs_11881_180_09'};    
    %classifs = {'class_532_5261_150_07_111_1_mr0','class_280_3736_200_07_111_1_mr0','class_831_11881_180_09_111_1_mr0'}; 
    segs = {'segmentation_configs_5261_150_07.mat','segmentation_configs_3736_200_07','segmentation_configs_3736_200_07','segmentation_configs_11881_180_09','segmentation_configs_11881_180_09'};
    classifs = {'class_532_5261_150_07_30_1_mr0','class_310_3736_200_07_30_1_mr0','class_280_3736_200_07_30_1_mr0','class_855_11881_180_09_60_1_mr0','class_855_11881_180_09_30_1_mr0'};
    head = {'CLASS','L150V70','L200V70','L200V70L','L180V90','L180V90LCLASS'};
    %head = {'CLASS','L150V70','L200V70','L180V90'};    
    R = 75;
    intervals = [R/4,R/2,R,(3/2)*R,2*R];
end
sigma = intervals;

%% Initialization
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
load(fullfile(input_dir,'animals_trajectories_map.mat'));
seg_path = fullfile(input_dir,'segmentation');
class_path = fullfile(input_dir,'Mclassification');
ext = 'merged_1.mat';
figures = 0;

ftabler = [];
for s = 1:length(sigma) %SIGMA
ftablec = [];    
for il = 1:length(intervals)%INTERVAL
    
    table_tmp = [];
    for i = 1:length(segs)
        spath = fullfile(seg_path,segs{i});
        cpath = fullfile(class_path,classifs{i},ext);
        load(spath);
        load(cpath);
        p_table1 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'INTERVAL',intervals(il),'SIGMA',sigma(s));
        p_table2 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'INTERVAL',intervals(il),'SIGMA',sigma(s));
        [class_map_detailed,~] = distr_strategies_smoothing(segmentation_configs, classification_configs, 'INTERVAL',intervals(il),'SIGMA',sigma(s));
        zero = length(find(class_map_detailed == 0));
        output_dir2 = fullfile(output_dir,'pics',classifs{i},strcat('int',num2str(intervals(il)),'_','sig',num2str(sigma(s))));
        if ~exist(output_dir2,'dir')
            mkdir(output_dir2);
        else
            rmdir(output_dir2,'s')
            mkdir(output_dir2);
        end
        results_full_classified_trajectories(segmentation_configs,classification_configs,output_dir2,'INTERVAL',intervals(il),'SIGMA',sigma(s))
        temp = [p_table1 ; p_table2 ; zero];
        table_tmp = [table_tmp , temp];           
    end
    labels = {};
    for i = 1:length(classification_configs.CLASSIFICATION_TAGS)
        labels{i,1} = classification_configs.CLASSIFICATION_TAGS{i}{2};
    end
    labels{end+1,1} = 'tr';
    labels{end+1,1} = 'UD';
    table_tmp = num2cell(table_tmp);
    table_tmp = [labels,table_tmp];
    table = cell2table(table_tmp,'VariableNames',head);
    str = strcat('results_smoothing_',num2str(intervals(il)),'_',num2str(sigma(s)),'.csv');
    writetable(table,fullfile(output_dir,str),'WriteVariableNames',1);   
    
    ftable_tmp = [head;table_tmp];
    ftable_tmp{1,1} = strcat(num2str(intervals(il)),'_',num2str(sigma(s)));
    ftablec = [ftablec,ftable_tmp];
    
end
ftabler = [ftabler;ftablec];
end
table = cell2table(ftabler);
writetable(table,fullfile(output_dir,'results_smoothing.csv'),'WriteVariableNames',0);   

% Classification result
temp = [];
table_tmp = [];
for i = 1:length(segs)
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath);
    load(cpath);
    p_table1 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'DISTRIBUTION',2);
    p_table2 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'DISTRIBUTION',2);
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
table = cell2table(table_tmp,'VariableNames',head);
writetable(table,fullfile(output_dir,'results_class.csv'),'WriteVariableNames',1);   
