function [error] = results_strategies_distributions_manual_full(project_path,segmentation_file,labels_file,animals_trajectories_map,figures)
% Computes the number of trajectories for each strategy adopted by two 
% groups of N animals for a set of M trials. Manual labelling is being used
% and the results are based on the percentage corresponding to each class
% which was computed as an average of identified classes in each swimming
% path.

    error = 1;
    
    % Check labels file and if it matches the selected segmentation
    t = strsplit(labels_file,{'_','.mat'});
    s = strsplit(segmentation_file,{'_','.mat'});
    try
        if ~isequal(t{3},'0') && ~isequal(t{4},'0')
            errordlg('Selected labelling file do not match the selected segmentation.','Error');
            return;
        end
        if str2double(t{2}) > str2double(s{3})
            errordlg('Selected labelling file do not match the selected segmentation.','Error');
            return;
        end
        if str2double(t{2}) < str2double(s{3})
            errordlg('All the segments needs to be manually labelled in order to continue.','Error');
            return;
        end
    catch
        errordlg('Selected labelling file do not match the selected segmentation.','Error');
        return
    end
    
    % Load labels and segmentation
    try
        load(char_project_path(fullfile(project_path,'segmentation',segmentation_file)));
        load(char_project_path(fullfile(project_path,'labels',labels_file)));
    catch
        errordlg('Error loading the labelling and segmentation files','Error');
        return; 
    end
    
    % Make the output folder
    folder_name = strcat('Strategies-traj_',s{3},'_',t{2},'_manual');
    output_dir = char_project_path(fullfile(project_path,'results',folder_name));
    try
        % delete the folder if already exists
        if exist(output_dir,'dir');
            f = fopen('all');
            for i = 1:length(f);
                fclose(f(i));
            end
            rmdir(output_dir,'s');
        end
        mkdir(output_dir);
    catch
        errordlg('Cannot create folder for the results');
        return
    end
            
    % Get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % Get number of trials
    trials_per_session = segmentation_configs.EXPERIMENT_PROPERTIES{30};
    total_trials = sum(trials_per_session);
    % Strategies distribution
    strat_distr = zeros(length(LABELLING_MAP),length(CLASSIFICATION_TAGS));
    for i = 1:length(LABELLING_MAP)
        tr = LABELLING_MAP{i};
        for j = 1:length(tr)
            strat_distr(i,tr(j)) = 1;
        end
    end

    % For one animal group
%     if length(animals_trajectories_map) == 1
%         [data_, groups_all, pos] = one_group_strategies(total_trials,segments_classification,animals_trajectories_map,long_trajectories_map,strat_distr,output_dir);
%         varargout{1} = data_;
%         varargout{2} = groups_all;
%         varargout{3} = pos;
%         return
%     end    
    
    % Generate text file for the p-values
    fn = fullfile(output_dir,'strategies_p.txt');
    fileID = fopen(fn,'wt');
   
    %% Friedman's test and collect data for plotting
    p_table = []; %for storing the p-values
    ncl = length(CLASSIFICATION_TAGS);
    tot_all = cell(1,ncl);
    pos_all = cell(1,ncl);
    
    for c = 1:ncl
        pos = [];
        d = 0.05;
        n = zeros(1,total_trials*2); %at the end each element = nanimals
        tot = zeros(1,total_trials*2);
        % Matrix for friedman's multifactor tests
        [animals_trajectories_map,nanimals] = friedman_test(animals_trajectories_map);
        mfried = zeros(nanimals*total_trials, 2);        
        for t = 1:total_trials
            for g = 1:2            
                map = animals_trajectories_map{g};
                idx = 2 * (t - 1) + g;
                for i = 1:nanimals      
                    if strat_distr(map(t, i),c) > 0
                        val = strat_distr(map(t, i),c) / sum(strat_distr(map(t, i),:));
                    else
                        val = 0;
                    end
                    n(idx) = n(idx) + 1;
                    tot(idx) = tot(idx) + val;
                    mfried((t - 1)*nanimals + i, g) = val;                                      
                end
                pos = [pos, d];
                d = d + 0.05;                 
            end     
            if rem(t, trials_per_session(1)) == 0
                d = d + 0.07;                
            end                
            d = d + 0.02;                
        end
        
        % Run friedman's test  
        p = -1;
        try
            p = friedman(mfried, nanimals, 'off');
            str = sprintf('Class: %s\tp_frdm: %g', CLASSIFICATION_TAGS{1,c}{1,2}, p);            
            fprintf(fileID,'%s\n',str);
            disp(str);
            p_table = [p_table;p];
        catch
            disp('Error on Friedman test. Friedman test is skipped');
            p_table = [p_table;p];
        end   

        tot_all{1,c} = tot;
        pos_all{1,c} = pos;  
    end     
    
    fclose(fileID);
    
    %% Generate figures
    if figures
        data_ = -1*ones(1,total_trials*2);
        data_all = cell(1,ncl);
        for c = 1:ncl
            f = figure;
            set(f,'Visible','off'); 
            for b = 1:(total_trials*2)   
                if n(b) > 0
                    data = tot_all{1,c}(b) / n(b);
                else
                    data = 0;
                end
                data_(b) = data;
                h = bar(pos_all{1,c}(b), data, 0.04);
                if mod(b, 2) == 0
                    set(h, 'facecolor', [0 0 0]);
                else
                    set(h, 'facecolor', [1 1 1]);
                end           
                hold on;
            end
            data_all{1,c} = data_;
            lbls = {};
            lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);    
            faxis = findobj(f,'type','axes');
            set(faxis, 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'FontSize', FontSize, 'FontName', FontName);
            set(faxis, 'Ylim', [0,1]);
            set(faxis, 'LineWidth', LineWidth);   
            title(CLASSIFICATION_TAGS{1,c}{1,2}, 'FontSize', FontSize, 'FontName', FontName)
            xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
            ylabel('percentage of trajectories', 'FontSize', FontSize, 'FontName', FontName); 
            set(f, 'Color', 'w');
            box off;  
            set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
            export_figure(f, output_dir, sprintf('animal_strategy_%d', c), Export, ExportStyle);
            close(f)
        end  
        
        % Export figure data
        for c = 1:ncl
            fpath = fullfile(output_dir,strcat('animal_strategy_',num2str(c),'.csv'));
            data = data_all{1,c};
            table = num2cell(data);
            header = cell(1,length(data));
            idx = 1;
            for b = 1:2:length(data);
                header{b} = strcat('trial',num2str(idx));
                header{b+1} = header{b};
                idx = idx + 1;
            end
            table = [header;table];
            table = cell2table(table);
            writetable(table,fpath,'WriteVariableNames',0);    
        end
    end
    error = 0;
end


