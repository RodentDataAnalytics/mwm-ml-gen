function create_average_figure(data,groups,positions,output_dir,total_trials,tags)
%CREATE_AVERAGE_STRAT_FIGURES generates one figure for each strategy that
%illustrates the average segment length of the strategy from all the
%classifiers

    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
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

    for i = 1:length(avg)
        f = figure;
        set(f,'Visible','off');
        pos = positions{1,i};
        boxplot(avg{1,i}, groups{1,i}, 'positions', positions{1,i}, 'colors', [0 0 0]);     
    
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
        end
        set(h, 'LineWidth', LineWidth);

        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', LineWidth);
        end

        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end        
         
        lbls = {};
        lbls = 1:total_trials;     

        try
            set(gca, 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'FontSize', FontSize, 'FontName', FontName);
            set(gca, 'Ylim', [0, max(avg{1,i})+0.5]);
            set(gca, 'LineWidth', LineWidth);   
        catch
            set(gca, 'XTickLabel', lbls, 'Ylim', [0, max(avg{1,i})+0.5], 'FontSize', FontSize, 'FontName', FontName);
            set(gca, 'LineWidth', LineWidth);
        end

        if length(avg) == 1
            ylabel('transitions', 'FontSize', FontSize, 'FontName', FontName);
        else
            ylabel(tags{i}{2}, 'FontSize', FontSize, 'FontName', FontName);
        end
        xlabel('trial', 'FontSize', FontSize);  

        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        
        if length(avg) == 1
            export_figure(f, output_dir, 'average_transitions', Export, ExportStyle);
        else
            export_figure(f, output_dir, sprintf('average_segment_length_strategy_%d', i), Export, ExportStyle);
        end
        close(f)
    end
    
    %% Export figures data
    box_plot_data(avg, groups, output_dir);
end