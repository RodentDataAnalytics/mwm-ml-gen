function [varargout] = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,varargin)
% Computes and presents the number of transitions between strategies 
% for two groups of N animals.
    
    % Get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % Get number of trials
    trials_per_session = segmentation_configs.EXPERIMENT_PROPERTIES{30};
    total_trials = sum(trials_per_session);
    % Get the transitions
    trans = transition_counts(segmentation_configs,classification_configs);
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs );
    % For one group
    if length(animals_trajectories_map) == 1
        [vals,vals_grps,pos] = one_group_transition_counts(animals_trajectories_map,long_trajectories_map,total_trials,trans,1,output_dir);
        varargout{1} = vals; % input data (vector)
        varargout{2} = vals_grps; % grouping variable (length(vals))
        varargout{3} = pos; % position of each boxplot in the figure  
        return
    end    

    % Matrix for friedman's multifactor tests
    [animals_trajectories_map,nanimals] = friedman_test(animals_trajectories_map);
    mfried = zeros(nanimals*total_trials, 2); 
    
    data = [];
    pos = [];       
    groups = [];
    d = 0.05; 
    grp = 1;

    for t = 1:total_trials
        for g = 1:2    
            map = animals_trajectories_map{g};
            pts = [];
            for i = 1:nanimals
                if long_trajectories_map(map(t, i)) ~= 0 
                    val = trans(map(t,i));
                    pts = [pts,val];
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
        fn = fullfile(output_dir,'transitions_p.txt');
        fileID = fopen(fn,'wt');
        p = friedman(mfried, nanimals, 'off');
        str = sprintf('p_frdm: %g', p); 
        fprintf(fileID,'%s\n',str);
        disp(str);
        fclose(fileID);
    catch
        disp('Error on Friedman test. Friedman test is skipped');
    end   

    %% Generate figure
    if figures
        f = figure;
        set(f,'Visible','off');

        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0]);   
        faxis = findobj(f,'type','axes');
        h = findobj(faxis,'Tag','Box');

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
        set(faxis, 'LineWidth', LineWidth);  
        set(faxis,'Ylim', [0, max(data)+5]);

        ylabel('transitions', 'FontSize', FontSize, 'FontName', FontName);
        xlabel('trial', 'FontSize', FontSize, 'FontName', FontName); 

        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        export_figure(f, output_dir, 'transition_counts', Export, ExportStyle);
        close(f)
    end
    
    %% Export figures data
    box_plot_data(data, groups, output_dir, 'transition_counts');
    
    %% Output
    varargout{1} = p; % Friedman's test p-value (-1 if it is skipped)
    varargout{2} = mfried; % Friedman's test sample data
    varargout{3} = nanimals; % Friedman's test num of replicates per cell
    varargout{4} = data; % input data (vector)
    varargout{5} = groups; % grouping variable (length(vals))
    varargout{6} = pos; % position of each boxplot in the figure   
    
    %Note for vals_grps: it holds numbers 1:nanimals and each number is
    %repeated nanimals times
end
    
