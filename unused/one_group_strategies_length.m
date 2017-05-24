function [varargout] = one_group_strategies_length(total_trials,segments_classification,animals_trajectories_map,long_trajectories_map,strat_distr,output_dir,path_interval)

    nanimals = size(animals_trajectories_map{1,1},2);

    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
    % plot distributions
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
                        
        for t = 1:total_trials
            for g = 1:length(animals_trajectories_map)            
                pts_session = [];
                map = animals_trajectories_map{1,g};
                pts = [];
                for i = 1:nanimals
                    if long_trajectories_map(map(t, i)) ~= 0                        
                        val = path_interval * sum(strat_distr(long_trajectories_map(map(t, i)), :) == c);
                        pts = [pts, val];
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
                pts_session = [pts_session, pts];
                pos = [pos, d];
                d = d + 0.05;                 
            end                                  
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

    for c = 1:segments_classification.nclasses
        f = figure;
        set(f,'Visible','off');
        
        boxplot(data_all{1,c}, groups_all{1,c}, 'positions', pos_all{1,c}, 'colors', [0 0 0]); 
        faxis = findobj(f,'type','axes');
        h = findobj(faxis,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
        end
        set(h, 'LineWidth', LineWidth);
                
        h = findobj(faxis, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0], 'LineWidth', LineWidth);
        end

        h = findobj(faxis, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end        
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        
        set(faxis, 'XTickLabel', lbls, 'Ylim', [0, max(data_all{1,c})+0.5], 'FontSize', FontSize, 'FontName', FontName);
        set(faxis, 'LineWidth', LineWidth);   
                 
        title(segments_classification.classes{1,c}{1,2}, 'FontSize', FontSize, 'FontName', FontName)
        xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
        ylabel('average segment length (m)', 'FontSize', FontSize, 'FontName', FontName); 
        
        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        
        export_figure(f, output_dir, sprintf('segment_length_strategy_%d', c), Export, ExportStyle);
        close(f);
    end     
    
    box_plot_data(data_all, groups_all, output_dir);
    
    %% Output
    varargout{1} = data_all;
    varargout{2} = groups_all;
    varargout{3} = pos_all;
end