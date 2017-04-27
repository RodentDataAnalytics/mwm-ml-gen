%% Use default values
p_table_1 = [];
ptable_1 = [];
ptable_2 = [];
wb = [];
wu = [];
for i = 1:4
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath)
    load(cpath)
    
    p_table1 = results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    p_table2 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    p_table3 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir);
    [~,~,~,w_bounded,w_unbounded] = distr_strategies_tiago(segmentation_configs, classification_configs);
    
    p_table_1 = [p_table1;p_table3];
    ptable_1 = [ptable_1,p_table_1];
    ptable_2 = [ptable_2,p_table2];
    wb = [wb;w_bounded];
    wu = [wu;w_unbounded];
end
store{1,1} = ptable_1;

fn = fullfile(npath,str{1});
fileID = fopen(fn,'wt');

for i = 1:length(segs)
    fprintf(fileID,'%s\n',segs{i});
end
fprintf(fileID,'results_strategies_distributions_length\n');
for i = 1:size(ptable_1,1)
    fprintf(fileID,'%s\n',num2str(ptable_1(i,:)));
end
fprintf(fileID,'\n\n');
fprintf(fileID,'results_strategies_distributions\n');
for i = 1:size(ptable_2,1)
    fprintf(fileID,'%s\n',num2str(ptable_1(i,:)));
end
fprintf(fileID,'\n\n');
fprintf(fileID,'results_strategies_weights_bounded\n');
for i = 1:size(wb,1)
    fprintf(fileID,'%s\n',num2str(wb(i,:)));
end
fprintf(fileID,'\n\n');
fprintf(fileID,'results_strategies_weights_unbounded\n');
for i = 1:size(wu,1)
    fprintf(fileID,'%s\n',num2str(wu(i,:)));
end    
fclose(fileID);
