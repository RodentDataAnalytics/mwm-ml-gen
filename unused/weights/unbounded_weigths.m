%% Use unbounded weights
p_table_1 = [];
ptable_1 = [];
ptable_2 = [];
for i = 1:4
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath)
    load(cpath)
    
    p_table1 = results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'HARD_BOUNDS',0);
    p_table2 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'HARD_BOUNDS',0);
    p_table3 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'HARD_BOUNDS',0);
    
    p_table_1 = [p_table1;p_table3];
    ptable_1 = [ptable_1,p_table_1];
    ptable_2 = [ptable_2,p_table2];
end
store{1,2} = ptable_1;

fn = fullfile(npath,str{2});
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
fclose(fileID);
