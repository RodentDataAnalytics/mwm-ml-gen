function [varargout] = results_strategies_distributions_length(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,varargin)
% Computes the average segment lengths for each strategy adopted by 
% two groups of N animals for a set of M trials The generated plots
% show the average length in meters that the animals spent in one strategy 
% during each trial (for S total strategies, were S is defined by the user)

    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % Get number of trials
    trials_per_session = segmentation_configs.EXPERIMENT_PROPERTIES{30};
    total_trials = sum(trials_per_session);
    % Get classification
    segments_classification = classification_configs.CLASSIFICATION;
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs ); 
    % Strategies distribution
    [strat_distr, ~, ~, ~] = distr_strategies(segmentation_configs, classification_configs);
    % path interval = length(1-overlap)
    path_interval = segmentation_configs.SEGMENTATION_PROPERTIES;
    path_interval = path_interval(1)*(1-path_interval(2));
    
    % For one animal group
    if length(animals_trajectories_map) == 1
        [data_, groups_all, pos] = one_group_strategies(total_trials,segments_classification,animals_trajectories_map,long_trajectories_map,strat_distr,output_dir,path_interval);
        varargout{1} = data_;
        varargout{2} = groups_all;
        varargout{3} = pos;
        return
    end    
    
    % Generate text file for the p-values
    fn = fullfile(output_dir,'strategies_p.txt');
    fileID = fopen(fn,'wt');
   
    %% Friedman's test and collect data for plotting
    p_table = []; %for storing the p-values
    ncl = segments_classification.nclasses;
    data_all = cell(1,ncl);
    groups_all = cell(1,ncl);
    pos_all = cell(1,ncl);
    maximum = 0;
    for c = 1:segments_classification.nclasses
        data = [];
        groups = [];
        pos = [];
        d = 0.05;
        grp = 1;

        % Matrix for friedman's multifactor tests
        [animals_trajectories_map,nanimals] = friedman_test(animals_trajectories_map);
        mfried = zeros(nanimals*total_trials, 2);                
        
        for t = 1:total_trials
            for g = 1:2            
                map = animals_trajectories_map{g};
                pts = [];
                for i = 1:nanimals
                    if long_trajectories_map(map(t, i)) ~= 0                        
                        val = path_interval * sum(strat_distr(long_trajectories_map(map(t, i)), :) == c);
                        pts = [pts, val];
                        mfried((t - 1)*nanimals + i, g) = val;
                    end                                           
                end
                if isempty(pts)
                    data = [data, 0];
                    groups = [groups, grp];
                else
                    data = [data, pts];
                    groups = [groups, ones(1, length(pts))*grp];
                end
                grp = grp + 1;
                pos = [pos, d];
                d = d + 0.05;                 
            end     
            if rem(t, 4) == 0
                d = d + 0.07;                
            end                
            d = d + 0.02;                
        end
        
        % Run friedman's test  
        p = -1;
        try
            p = friedman(mfried, nanimals, 'off');
            str = sprintf('Class: %s\tp_frdm: %g', segments_classification.classes{1,c}{1,2}, p);            
            fprintf(fileID,'%s\n',str);
            disp(str);
            p_table = [p_table;p];
        catch
            disp('Error on Friedman test. Friedman test is skipped');
            p_table = [p_table;p];
        end   
        
        % collect all the data and store maximum data number
        a = max(data)/1000;
        if a > maximum
            maximum = a;
        end    
        data_all{1,c} = data./1000;
        groups_all{1,c} = groups;
        pos_all{1,c} = pos;  
    end     
    fclose(fileID);
    
    %% Generate figures
    if figures
        for c = 1:segments_classification.nclasses
            f = figure;
            set(f,'Visible','off');
            
            boxplot(data_all{1,c}, groups_all{1,c}, 'positions', pos_all{1,c}, 'colors', [0 0 0]);     
            faxis = findobj(f,'type','axes');
            h = findobj(f,'Tag','Box');
            for j=1:2:length(h)
                 patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
            end
            set(h, 'LineWidth', LineWidth);

            h = findobj(faxis, 'Tag', 'Median');
            for j=1:2:length(h)
                 line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', LineWidth);
            end

            h = findobj(faxis, 'Tag', 'Outliers');
            for j=1:length(h)
                set(h(j), 'MarkerEdgeColor', [0 0 0]);
            end        

            lbls = {};
            lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     

            set(faxis, 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'FontSize', FontSize, 'FontName', FontName);
            set(faxis, 'Ylim', [0, max(data_all{1,c})+0.5]);
            set(faxis, 'LineWidth', LineWidth);   

            ylabel(segments_classification.classes{1,c}{1,2}, 'FontSize', FontSize, 'FontName', FontName);
            xlabel('trial', 'FontSize', FontSize);  

            set(f, 'Color', 'w');
            box off;  
            set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
            export_figure(f, output_dir, sprintf('segment_length_strategy_%d', c), Export, ExportStyle);
            close(f)
        end    
    end
    
    %% Export figures data
    box_plot_data(data_all, groups_all, output_dir);
    
    %% Output
    varargout{1} = p_table; % Friedman's test p-value (-1 if it is skipped)
    varargout{2} = mfried; % Friedman's test sample data
    varargout{3} = nanimals; % Friedman's test num of replicates per cell
    varargout{4} = data_all; % input data (matrix of vectors) [data/1000]
    varargout{5} = groups_all; % grouping variable (length(data_))
    varargout{6} = pos_all; % position of each boxplot in the figure   
    
    %Note for vals_grps: it holds numbers 1:nanimals and each number is
    %repeated nanimals times
end

