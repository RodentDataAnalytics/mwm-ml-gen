function [varargout] = results_strategies_distributions_length2(ppath,labels_path,animals_trajectories_map,figures,output_dir,varargin)
% Computes the average segment lengths for each strategy adopted by 
% two groups of N animals for a set of M trials The generated plots
% show the average length in meters that the animals spent in one strategy 
% during each trial (for S total strategies, were S is defined by the user)

    LONG_TRAJECTORIES_MAP = 0;
    figures = 1;
    output_dir = 'C:\Users\Avgoustinos\Documents\MWMGEN\EPFL_original_data\results\test_full';
    ppath = 'C:\Users\Avgoustinos\Documents\MWMGEN\EPFL_original_data';
    %labels_path = 'C:\Users\Avgoustinos\Documents\MWMGEN\EPFL_original_data\labels\labels_684_0_0_s1.csv';
    labels_path = 'C:\Users\Avgoustinos\Documents\MWMGEN\EPFL_original_data\labels\labels_684_0_0.csv';

    % Get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;   
    % Get project path
    ppath = char_project_path(ppath);       
    % Load necessary files from 'settings' folder
    files = fullfile(ppath,'settings','*.mat');
    if isempty(files)
        errordlg('No data have been imported for this project');
    end
    try
        load(fullfile(ppath,'settings','new_properties.mat'));
        load(fullfile(ppath,'settings','animal_groups.mat'));
        load(fullfile(ppath,'settings','my_trajectories.mat'));
    catch
        errordlg('Cannot load project settings','Error');
        return
    end
    % Get number of trials
    trials_per_session = new_properties{30};
    total_trials = sum(trials_per_session);
    
    % Compute trajectory features
    traj_length  = features_list;
    traj_length  = traj_length(10);
    traj_length = compute_features(my_trajectories.items, traj_length, new_properties);
    k = 1;
    for i = 1:length(my_trajectories.items)
        if traj_length(i) < 200
            long_trajectories_map(i) = 0;
        else
            long_trajectories_map(i) = k;
            k = k + 1;
        end
    end
    
    % Get other tags
    tags = tags_list(1);
    % Read labels and create the strategies discribution per trajectory
    tags_data = read_tags(labels_path); %cell array: {traj no. , {label1,...,labelN}}
    full_map = zeros(length(my_trajectories.items),length(tags));
    for i = 1:length(tags_data)
        idx = tags_data{i}{1};
        labels = tags_data{i}{2};
        for j = 1:length(labels)
            for t = 1:length(tags)
                if isequal(labels{j},tags{t}{1})
                    full_map(idx,t) = 1;
                    break;
                end
            end
        end
    end
    
    % For one animal group
    if length(animals_trajectories_map) == 1
        %[data_, groups_all, pos] = one_group_strategies(total_trials,segments_classification,animals_trajectories_map,long_trajectories_map,strat_distr,output_dir,path_interval);
        %varargout{1} = data_;
        %varargout{2} = groups_all;
        %varargout{3} = pos;
        return
    end    
    
    % Generate text file for the p-values
    fn = fullfile(output_dir,'strategies_p.txt');
    fileID = fopen(fn,'wt');
   
    %% Friedman test and collect data for plotting
    p_table = zeros(length(tags),1); %for storing the p-values
    tot_all = cell(1,length(tags));
    n_all = cell(1,length(tags));
    pos_all = cell(1,length(tags));
       
    for c = 1:length(tags)
        pos = [];
        d = 0.05;       
        n = zeros(1, total_trials*2);
        tot = zeros(1, total_trials*2);

        % Matrix for friedman's multifactor tests
        [animals_trajectories_map,nanimals] = friedman_test(animals_trajectories_map);
        mfried = zeros(nanimals*total_trials, 2);                
        
        for t = 1:total_trials
            for g = 1:2            
                map = animals_trajectories_map{g};
                idx = 2*(t - 1) + g;
                for i = 1:nanimals
                    if LONG_TRAJECTORIES_MAP
                        if long_trajectories_map(map(t, i)) ~= 0                     
                            if full_map(map(t, i), c) > 0
                                val = full_map(map(t, i), c)/sum(full_map(map(t, i), :));
                            else
                                val = 0;
                            end
                            tot(idx) = tot(idx) + val;
                            n(idx) = n(idx) + 1;
                            mfried((t - 1)*nanimals + i, g) = val;
                        end
                    else
                        if full_map(map(t, i), c) > 0
                            val = full_map(map(t, i), c)/sum(full_map(map(t, i), :));
                        else
                            val = 0;
                        end  
                        tot(idx) = tot(idx) + val;
                        n(idx) = n(idx) + 1;
                        mfried((t - 1)*nanimals + i, g) = val;
                    end      
                end
                pos = [pos, d];
                d = d + 0.05; 
            end
            if rem(t, 4) == 0
                d = d + 0.07;                
            end                
            d = d + 0.02;                
        end                
                       
        % Run the Friedman test  
        p = -1;
        try
            p = friedman(mfried, nanimals, 'off');
            str = sprintf('Class: %s\tp_frdm: %g', tags{1,c}{1,2}, p);            
            fprintf(fileID,'%s\n',str);
            disp(str);
            p_table(c) = p;
        catch
            disp('Error on Friedman test. Friedman test is skipped');
            p_table(c) = p;
        end   
        
        % collect all the data and store maximum data number
        tot_all{1,c} = tot;
        n_all{1,c} = n;
        pos_all{1,c} = pos;  
    end     
    fclose(fileID);
    
    %% Generate figures
    lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);  
    if figures
        for c = 1:length(tags)
            f = figure;
            set(f,'Visible','off');
            
            pos = pos_all{1,c};
            tot = tot_all{1,c};
            n = n_all{1,c};
            lim = max(tot_all{1,c}./n_all{1,c});
            if lim == 0
                continue;
            end
            
            % black & white bars
            for j = 1:total_trials*2
                h = bar(pos(j), tot(j) / n(j), 0.04);
                if mod(j, 2) == 0
                    set(h, 'facecolor', [0 0 0]);
                else
                    set(h, 'facecolor', [1 1 1]);
                end           
                hold on;   
            end
        
            % fix plot
            faxis = findobj(f,'type','axes');
            set(faxis, 'DataAspectRatio', [1, lim*1.25, 1], 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);             
            title(tags{1,c}{1,2}, 'FontSize', FontSize, 'FontName', FontName)
            xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
            ylabel('average percentage of class', 'FontSize', FontSize, 'FontName', FontName);      
            set(gcf, 'Color', 'w');
            box off;  
            set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);
            export_figure(f, output_dir, sprintf('trajectories_strategy_%d', c), Export, ExportStyle);
            close(f)
        end
    end

    %% Export figures data
    %box_plot_data(data_all, groups_all, output_dir);
    
    %% Output
    %varargout{1} = p_table; % Friedman's test p-value (-1 if it is skipped)
    %varargout{2} = mfried; % Friedman's test sample data
    %varargout{3} = nanimals; % Friedman's test num of replicates per cell
    %varargout{4} = data_all; % input data (matrix of vectors) [data/1000]
    %varargout{5} = groups_all; % grouping variable (length(data_))
    %varargout{6} = pos_all; % position of each boxplot in the figure   
    varargout{1} = 1;
    %Note for vals_grps: it holds numbers 1:nanimals and each number is
    %repeated nanimals times
end