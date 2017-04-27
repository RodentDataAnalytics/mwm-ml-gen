%input_dir = uigetdir('','Specify project folder');
%output_dir = uigetdir('','Specify output folder');
input_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data'; 
output_dir = 'D:\test_results';

str_seg = {'segmentation_configs_8447_300_07.mat',...
           'segmentation_configs_10388_250_07.mat',...
           'segmentation_configs_29476_250_09.mat',...
           'segmentation_configs_13283_200_07.mat'};
       
str_class = {'class_989_8447_300_07',...
             'class_1301_10388_250_07',...
             'class_2447_29476_250_09',...
             'class_995_13283_200_07'};
         
load(fullfile(input_dir,'animals_trajectories_map.mat'));

for i = 1:4
    for k = 1:2               
        load(fullfile(input_dir,'segmentation',str_seg{i}));
        input_path = fullfile(input_dir,'classification',str_class{i});
        if k == 1
            h = waitbar(0,'Generating results: strats','Name','Results');
            output_path = fullfile(output_dir,'strats',str_seg{i});
            class_tags = classifications{1}.CLASSIFICATION_TAGS;
        elseif k == 2
            h = waitbar(0,'Generating results: trans','Name','Results');
            output_path = fullfile(output_dir,'trans',str_seg{i});
            class_tags = {{'Transitions','Transitions',0,0}};
        end
        if exist(output_path,'dir');
            rmdir(output_path,'s');
        end
        mkdir(output_path);
        files = dir(fullfile(input_path,'*.mat'));
        files = {files.name};
        [num, idx] = sort_classifiers(files);
        files = files(:,idx);
        % % % % % % % % % %
        N = length(files);
        %N = 21;
        % % % % % % % % % %
        classifications = cell(1,N);
        dir_list = cell(1,N+1);
        for j = 1:N;
            clear classification_configs;
            load(fullfile(input_path,files{j}));
            classifications{j} = classification_configs;
            
            dir_list{j} = fullfile(output_path,strcat('g12res_',num2str(num(j))));
            mkdir(dir_list{j});
        end
        dir_list{end} = fullfile(output_path,'g12res_summary');
        mkdir(dir_list{end});   

        %Friedman's test p-value (-1 if it is skipped)
        p_ = cell(1,length(classifications));
        %Friedman's test sample data
        mfried_ = cell(1,length(classifications));
        %Friedman's test num of replicates per cell
        nanimals_ = cell(1,length(classifications));
        %Input data (vector)
        vals_ = cell(1,length(classifications)); 
        %Grouping variable (length(x))
        vals_grps_ = cell(1,length(classifications)); 
        %Position of each boxplot in the figure  
        pos_ = cell(1,length(classifications));  
        
        if k == 1
            for j = 1:length(classifications);
                [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions_length(segmentation_configs,classifications{j},animals_trajectories_map,1,dir_list{j});
                %[p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                p_{j} = p;
                mfried_{j} = mfried;
                nanimals_{j} = nanimals;
                vals_{j} = vals;
                vals_grps_{j} = vals_grps;
                pos_{j} = pos;
                waitbar(j/length(classifications)); 
            end
            fpath = fullfile(dir_list{end},'pvalues_summary.csv');
            error = create_pvalues_table(p_,class_tags,fpath);
            error = create_pvalues_figure(p_,class_tags,dir_list{end});
        elseif k == 2
            for j = 1:length(classifications)
                [p,mfried,nanimals,vals,vals_grps,pos] = results_transition_counts(segmentation_configs,classifications{j},animals_trajectories_map,1,dir_list{j});
                p_{j} = p;
                mfried_{j} = mfried;
                nanimals_{j} = nanimals;
                vals_{j} = vals;
                vals_grps_{j} = vals_grps;
                pos_{j} = pos;
                waitbar(j/length(classifications)); 
            end
            fpath = fullfile(dir_list{end},'pvalues_summary.csv');
            error = create_pvalues_table(p_,class_tags,fpath);
            error = create_pvalues_figure(p_,class_tags,dir_list{end},'tag',{''},'xlabel','transitions');
        end
        delete(h);
    end
end


