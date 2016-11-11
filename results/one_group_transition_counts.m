function [varargout] = one_group_transition_counts(animals_trajectories_map,long_trajectories_map,total_trials,trans,figures,output_dir)

    nanimals = size(animals_trajectories_map{1,1},2);

    % Get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
    data = [];
    pos = [];       
    groups = [];
    d = 0.05; 
    grp = 1;
                
    for t = 1:total_trials
        for g = 1:length(animals_trajectories_map)    
            map = animals_trajectories_map{1,g};
            pts = [];
            for i = 1:nanimals
                if long_trajectories_map(map(t, i)) ~= 0 
                    val = trans(map(t,i));
                    pts = [pts,val];
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
    
    % Generate figure
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

        set(faxis, 'XTickLabel', lbls, 'Ylim', [0, max(data)+0.5], 'FontSize', FontSize, 'FontName', FontName);
        set(faxis, 'LineWidth', LineWidth);  

        ylabel('transitions', 'FontSize', FontSize, 'FontName', FontName);
        xlabel('trial', 'FontSize', FontSize, 'FontName', FontName); 

        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        export_figure(f, output_dir, 'transision_counts', Export, ExportStyle);
        close(f)
    end
    
    box_plot_data(data, groups, output_dir, 'transition_counts');
    
    %% Output
    varargout{1} = data; % input data (vector)
    varargout{2} = groups; % grouping variable (length(x))
    varargout{3} = pos; % position of each boxplot in the figure  
end
