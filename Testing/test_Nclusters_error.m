
input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data\results\test';

load(fullfile(input_dir,'animals_trajectories_map.mat'));

str_seg = {'segmentation_configs_8447_300_07.mat',...
           'segmentation_configs_10388_250_07.mat',...
           'segmentation_configs_29476_250_09.mat',...
           'segmentation_configs_13283_200_07.mat',...
           'segmentation_configs_13283_200_07.mat'};
str_class = {'class_989_8447_300_07',...
            'class_1301_10388_250_07',...
            'class_2445_29476_250_09',...
            'class_995_13283_200_07',...
            'class_1050_13283_200_07'};           
Nclusters = [43,46,47,46,98 ; 58,60,67,74,100 ; 86,90,97,85,120]'; %5,7,10%
str = {'TT';'IC';'SC';'FS';'CR';'SO';'SS';'ST';'tr'};
e_str = {'5%','7%','10%'};
top = {'300v07','250v07','250v09','200v07','200v07M'};

% 1 iteration
matrix_all = [];
for i = 1:size(Nclusters,2)
    tmp = [];
    for s = 1:length(str_seg)
        load(fullfile(input_dir,'segmentation',str_seg{s}));
        class_folder = fullfile(input_dir,'classification',str_class{s});
        % sort
        files = dir(fullfile(class_folder,'*.mat'));
        files = {files.name};
        [num, idx] = sort_classifiers(files);
        files = files(:,idx);
        % Mclass
        N = Nclusters(s,i);
        [~,Mclass_folder] = execute_Mclassification(input_dir, str_class(s), N, 1, 0,'CLUSTERS',10:10+N-1,'LWAITBAR',0);
        file = dir(fullfile(Mclass_folder,'*.mat'));   
        load(fullfile(Mclass_folder,file(1).name));
        
        [~,class,~] = fileparts(Mclass_folder);
        [~,name,classifications] = check_classification(input_dir,segmentation_configs,class);
        %% Smoothing
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Strategies',[1,2],'DISTRIBUTION',3); 
        tmp1 = getp(rpath,1);
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Transitions',[1,2],'DISTRIBUTION',3);
        tmp2 = getp(rpath,2);
        tmpS = [tmp1;tmp2];
        %% No smoothing
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Strategies',[1,2],'DISTRIBUTION',2);
        tmp1 = getp(rpath,1);   b
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Transitions',[1,2],'DISTRIBUTION',2);        
        tmp2 = getp(rpath,2);
        tmpNS = [tmp1;tmp2]; 
        %% Organise
        tt = [tmpS;tmpNS];
        tmp = [tmp,tt];
    end
    left = [e_str{i};str];
    all = [top;num2cell(tmp)];
    left = [left;str];
    matrix = [left,all];   
    matrix_all = [matrix_all,matrix];
    T = cell2table(matrix_all);
    writetable(T,fullfile(output_dir,strcat('testMiter_',num2str(i),'.csv')),'WriteVariableNames',0);
end
T = cell2table(matrix_all);
writetable(T,fullfile(output_dir,'testM_1.csv'),'WriteVariableNames',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% I iterations
I = 20;
M = 10;
matrix_all = [];
for i = 1:size(Nclusters,2)
    tmp = [];
    for s = 1:length(str_seg)
        load(fullfile(input_dir,'segmentation',str_seg{s}));
        class_folder = fullfile(input_dir,'classification',str_class{s});
        % Sort
        files = dir(fullfile(class_folder,'*.mat'));
        files = {files.name};
        [num, idx] = sort_classifiers(files);
        files = files(:,idx);
        % Mclass
        N = Nclusters(s,i);
        [~,Mclass_folder] = execute_Mclassification(input_dir, str_class(s), M, 20, 0,'CLUSTERS',10:10+N-1,'LWAITBAR',0);
        file = dir(fullfile(Mclass_folder,'*.mat'));   
        load(fullfile(Mclass_folder,file(1).name));
        
        [~,class,~] = fileparts(Mclass_folder);
        [~,name,classifications] = check_classification(input_dir,segmentation_configs,class);
        %% Smoothing
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Strategies',[1,2],'DISTRIBUTION',3); 
        tmp1 = getp(rpath,1);
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Transitions',[1,2],'DISTRIBUTION',3);
        tmp2 = getp(rpath,2);
        tmpS = [tmp1;tmp2];
        %% No smoothing
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Strategies',[1,2],'DISTRIBUTION',2);
        tmp1 = getp(rpath,1);
        [~,rpath] = generate_results(input_dir, name, segmentation_configs, classifications, animals_trajectories_map,'Transitions',[1,2],'DISTRIBUTION',2);        
        tmp2 = getp(rpath,2);
        tmpNS = [tmp1;tmp2]; 
        %% Organise
        tt = [tmpS;tmpNS];
        tmp = [tmp,tt];
    end
    left = [e_str{i};str];
    all = [top;num2cell(tmp)];
    left = [left;str];
    matrix = [left,all];   
    matrix_all = [matrix_all,matrix];
    T = cell2table(matrix_all);
    writetable(T,fullfile(output_dir,strcat('testMiter_',num2str(i),'.csv')),'WriteVariableNames',0);
end
T = cell2table(matrix_all);
fstr = strcat('testM_',num2str(I),'.csv');
writetable(T,fullfile(output_dir,fstr),'WriteVariableNames',0);