function one_group_metrics(animals_trajectories_map,vars,total_trials,days,trials_per_session,FontName,FontSize,LineWidth,Export,ExportStyle,output_dir)
%results_latency_speed_length for one group only
    
    % Figure strings
    names = {'latency' , 'speed' , 'length'};
    ylabels = {'latency [s]', 'speed [cm/s]', 'path length [m]'};
    
    for i = 1:size(vars, 1)
        values = vars(i, :);
        data = [];
        groups = [];
        d = .1;
        idx = 1;
        pos = zeros(1, total_trials);
        for s = 1:days
            for t = 1:trials_per_session                   
                pos(idx) = d;
                d = d + 0.1;
                idx = idx + 1;
                d = d + 0.07;
            end
            d = d + 0.15;
        end
                         
        for t = 1:total_trials    
            g = 1;
            map = animals_trajectories_map{g};
            tmp = values(map(t, :));                 
            data = [data, tmp(:)'];          
            groups = [groups, repmat(t*2 - 1 + g - 1, 1, length(tmp(:)))];
        end
        
        box_plot_data(data, groups, output_dir, names{i});
                   
        f = figure;
        set(f,'Visible','off');
        
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0]);
        faxis = findobj(f,'type','axes');
        set(faxis, 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        
        set(faxis, 'XLim', [0, max(pos) + 0.1], 'XTickLabel', lbls, 'Ylim', [0 max(data)+20], 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);                 
        set(faxis, 'Yscale', 'linear');        

        ylabel(ylabels{i}, 'FontSize', FontSize, 'FontName', FontName);
        xlabel('trial', 'FontSize', FontSize, 'FontName', FontName);

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
        
        set(f, 'Color', 'w');
        box off;        
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        
        export_figure(f, output_dir, sprintf('g1_animals_%s', names{i}), Export, ExportStyle); 
        close(f);
    end        
end

