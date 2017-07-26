function create_average_figure(animals_trajectories_map,data,groups,positions,output_dir,total_trials,tags)
%CREATE_AVERAGE_FIGURE_PER generates one figure for each strategy that
%illustrates the average number of segments that fall under each  
%strategy throughout the trials.

    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    nanimals = size(animals_trajectories_map{1,1},2);
    
    sub_data = {};
    for i = 1:length(data)
        sub_data = [sub_data;data{i}];
    end
    avg = cell(1,size(sub_data,2));
    for i = 1:size(sub_data,2)
        strat = cell2mat(sub_data(:,i));
        strat = mean(strat);
        avg{i} = strat;
    end
    
    if isequal(tags{1}{2},'Transitions')
        xx = 0;
    else
        xx = 1;
    end

    for i = 1:length(avg)-xx
        f = figure;
        set(f,'Visible','off');
        boxplot(avg{1,i}, groups{1,i}, 'positions', positions, 'colors', [0 0 0]);     
        faxis = findobj(f,'type','axes');

        % Box color
        h = findobj(f,'Tag','Box');
        if length(animals_trajectories_map) > 1
            for j=1:2:length(h)
                 patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
            end
        else
            for j=1:length(h)
                 patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
            end       
        end
        set(h, 'LineWidth', LineWidth);

        % Median
        h = findobj(faxis, 'Tag', 'Median');
        if length(animals_trajectories_map) > 1
            for j=1:2:length(h)
                 line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.8 .8 .8], 'LineWidth', 2);
            end
            for j=2:2:length(h)
                 line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.0 .0 .0], 'LineWidth', 2);
            end
        else
            for j=1:length(h)
                 line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.8 .8 .8], 'LineWidth', 2);
            end                
        end

        % Outliers
        h = findobj(faxis, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end      

        %Axes
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        if length(animals_trajectories_map) > 1
            set(faxis, 'XTick', (positions(1:2:2*total_trials - 1) + positions(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'FontSize', FontSize, 'FontName', FontName);
            set(faxis, 'Ylim', [0, max(avg{1,i})+0.5]);
        else
            set(faxis, 'XTickLabel', lbls, 'Ylim', [0, max(avg{1,i})+0.5], 'FontSize', FontSize, 'FontName', FontName);
        end
        set(faxis, 'LineWidth', LineWidth); 
        
        xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
        if ~xx
            ylabel('average transitions', 'FontSize', FontSize, 'FontName', FontName);
            title('transitions', 'FontSize', FontSize, 'FontName', FontName);
        else
            ylabel('average number of class segments', 'FontSize', FontSize, 'FontName', FontName);
            if i > length(tags)
                title('Direct Finding', 'FontSize', FontSize, 'FontName', FontName)
            else
                title(tags{i}{2}, 'FontSize', FontSize, 'FontName', FontName)
            end
        end 

        %Overall
        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        %Export and delete
        if ~xx
            export_figure(f, output_dir, 'average_animal_transitions', Export, ExportStyle);
        else
            export_figure(f, output_dir, sprintf('average_animal_strategy_%d', i), Export, ExportStyle);
        end
        delete(f)
    end
    
    %% Export figures data
    box_plot_data(nanimals, avg, groups, output_dir);
end