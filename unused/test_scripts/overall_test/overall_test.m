
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
%input_dir = uigetdir('','Specify project folder');
%output_dir = uigetdir('','Specify output folder');
input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
output_dir = 'C:\Users\Avgoustinos\Desktop\test_results\test_results';

segs = {'segmentation_configs_8447_300_07.mat',...
        'segmentation_configs_10388_250_07.mat',...
        'segmentation_configs_29476_250_09.mat',...
        'segmentation_configs_13283_200_07.mat'};
%vector^2 = vectorTvector - > 1xN Nx1 -- > 1x1    
classifs = {'class_989_8447_300_07_111_1_mr0',...
            'class_1301_10388_250_07_111_1_mr0',...
            'class_2447_29476_250_09_111_1_mr0',...
            'class_995_13283_200_07_111_1_mr0'};
        
% classifs = {'class_989_8447_300_07_21_1_mr0',...
%             'class_1301_10388_250_07_21_1_mr0',...
%             'class_2447_29476_250_09_21_1_mr0',...
%             'class_995_13283_200_07_21_1_mr0'};        
        
load(fullfile(input_dir,'animals_trajectories_map.mat'));
seg_path = fullfile(input_dir,'segmentation');
class_path = fullfile(input_dir,'Mclassification');
ext = 'merged_1.mat';
figures = 0;
store = cell(1,4);

%% Make the output folder tree
folder = fullfile(output_dir,'test_results');
if exist(folder,'dir')
    rmdir(folder,'s');
end
mkdir(folder);
npath = fullfile(output_dir,'test_results');
str = {'default_values.txt','unbounded_weights.txt','weights_ones.txt','classification_results.txt'};

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

%% Use weights = ones
p_table_1 = [];
ptable_1 = [];
ptable_2 = [];
for i = 1:4
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath)
    load(cpath)
    
    p_table1 = results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'OPTION',1);
    p_table2 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'OPTION',1);
    p_table3 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'OPTION',1);
    
    p_table_1 = [p_table1;p_table3];
    ptable_1 = [ptable_1,p_table_1];
    ptable_2 = [ptable_2,p_table2];
end
store{1,3} = ptable_1;

fn = fullfile(npath,str{3});
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

%% Use classification's results
p_table_1 = [];
ptable_1 = [];
ptable_2 = [];
for i = 1:4
    spath = fullfile(seg_path,segs{i});
    cpath = fullfile(class_path,classifs{i},ext);
    load(spath)
    load(cpath)
    
    p_table1 = results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'OPTION',2);
    p_table2 = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'OPTION',2);
    p_table3 = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,'OPTION',2);
    
    p_table_1 = [p_table1;p_table3];
    ptable_1 = [ptable_1,p_table_1];
    ptable_2 = [ptable_2,p_table2];
end
store{1,4} = ptable_1;

fn = fullfile(npath,str{4});
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


%% Weights Figures
% subfigures titles
titles = {'seg 300 07','seg 250 07','seg 250 09','seg 200 07'};
% get abbreviations and form x-axis tick names
class_tags = classification_configs.CLASSIFICATION_TAGS;
t = cell(1,length(class_tags)+2);
t{1} = ' ';
for i = 1:length(class_tags)
    t{i+1} = class_tags{i}{1};
end
t{end} = ' ';

fig = figure('units','normalized','outerposition',[0 0 1 1]);
for iter = 1:4
    % get the average weight
    [~,avg_w] = hard_bounds(wu(iter,:));
    % plot the average weight
    f = subplot(2,2,iter);
    plot([0,length(class_tags)+1],[avg_w,avg_w],'color','black','LineStyle','--','LineWidth',2.5);
    hold on
    % find the position of the max weight
    [~,pos] = max(wu(iter,:));
    % plot each class unbounded
    for i = 1:size(wu,2)
        b = bar(i,wu(iter,i));
        set(b,'FaceColor','white','LineWidth',1.5);
        % if this bar has max weight paint it red
        if wb(iter,i) ~= 1
            set(b,'FaceColor','black','LineWidth',0.5);
        end
        % if it is the bar with the max weight write it on top
        if i == pos
            text(i,wu(iter,i), num2str(wu(iter,i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize', FontSize, 'FontName', FontName, 'FontWeight', 'bold');
        end
        % if it is the bar with the min weight write it on top
        if wu(iter,i) == 1
            text(i,wu(iter,i), num2str(wu(iter,i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize', FontSize, 'FontName', FontName, 'FontWeight', 'bold');
        end
    end      
    % add title
    title(titles{iter}); 
    % correct the axis limits
    axis([0 length(class_tags)+1 0 round(max(max(wb)))+1]);
    % add tags & correct xticks
    faxis = findobj(f,'type','axes'); 
    xticks = [];
    for i = 1:length(class_tags)+2
        xticks = [xticks, i-1];
    end
    set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
    hold off
end
export_figure(fig, npath, 'class_weights', Export, ExportStyle);
close(fig);


%% Different Approaches Figures: Per Methodology
% get abbreviations and form x-axis tick names
class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};
t = cell(1,length(class_tags)+2);
t{1} = ' ';
for i = 1:length(class_tags)
    t{i+1} = class_tags{i}{1};
end
t{end} = ' ';
% titles and subtitles
titles = {'seg 300 07','seg 250 07','seg 250 09','seg 200 07'};
subtitles = {'Default','W=Unbounded','W=Ones','Class Results'};
s_names = {'seg_300_07','seg_250_07','seg_250_09','seg_200_07'};

for z = 1:length(titles)
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    title(titles{z}); 
    for iter = 1:4
        f = subplot(2,2,iter);
        % Friedman test threshold (0.05)
        plot([0,length(class_tags)+1],[0.05,0.05],'color','black','LineStyle','--','LineWidth',1.5);
        hold on
        % plot each class
        for i = 1:size(store{1},1)
            b = bar(i,store{iter}(i,z));
            set(b,'FaceColor','black','LineWidth',0.5);
            if store{iter}(i,z) < 0.05
                set(b,'FaceColor','white','LineWidth',1.5);
            end
        end
        % add title
        title(subtitles{iter}); 
        % correct the axis limits
        axis([0 length(class_tags)+1 0 0.15]);
        % add tags & correct xticks
        faxis = findobj(f,'type','axes'); 
        xticks = [];
        for i = 1:length(class_tags)+2
            xticks = [xticks, i-1];
        end
        set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
        hold off
    end
    export_figure(fig, npath, sprintf('per_method_%s',s_names{z}), Export, ExportStyle);
    close(fig);
end


%% Different Approaches Figures: Per Segmentation
% get abbreviations and form x-axis tick names
class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};
t = cell(1,length(class_tags)+2);
t{1} = ' ';
for i = 1:length(class_tags)
    t{i+1} = class_tags{i}{1};
end
t{end} = ' ';
% titles and subtitles
subtitles = {'seg 300 07','seg 250 07','seg 250 09','seg 200 07'};
titles = {'Default','W=Unbounded','W=Ones','Class Results'};
s_names = {'Default','W_Unbounded','W_Ones','Class_Results'};

for z = 1:length(titles)
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    title(titles{z}); 
    for iter = 1:4
        f = subplot(2,2,iter);
        % Friedman test threshold (0.05)
        plot([0,length(class_tags)+1],[0.05,0.05],'color','black','LineStyle','--','LineWidth',1.5);
        hold on
        % plot each class
        for i = 1:size(store{1},1)
            b = bar(i,store{z}(i,iter));
            set(b,'FaceColor','black','LineWidth',0.5);
            if store{z}(i,iter) < 0.05
                set(b,'FaceColor','white','LineWidth',1.5);
            end
        end
        % add title
        title(subtitles{iter}); 
        % correct the axis limits
        axis([0 length(class_tags)+1 0 0.15]);
        % add tags & correct xticks
        faxis = findobj(f,'type','axes'); 
        xticks = [];
        for i = 1:length(class_tags)+2
            xticks = [xticks, i-1];
        end
        set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
        hold off
    end
    export_figure(fig, npath, sprintf('per_seg_%s',s_names{z}), Export, ExportStyle);
    close(fig);
end
