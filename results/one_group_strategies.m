function one_group_strategies(segmentation_configs,total_trials,segments_classification,animals_trajectories_map,long_trajectories_map,strat_distr)

    lim = [90, 60, 13, 25, 25, 13, 25, 18]*25;
    nanimals = size(animals_trajectories_map{1,1},2);
    fontsize = 12;
    
    % plot distributions
    for c = 1:segments_classification.nclasses
        data = [];
        groups = [];
        pos = [];
        d = 0.05;
        grp = 1;
                        
        if c == segments_classification.nclasses                        
            last = 1;
        else
            last = 0;
        end

        for t = 1:total_trials
            for g = 1:length(animals_trajectories_map)            
                tot = 0;
                pts_session = [];
                map = animals_trajectories_map{1,g};
                pts = [];
                for i = 1:nanimals
                    if long_trajectories_map(map(t, i)) ~= 0                        
                        val = 25*sum(strat_distr(long_trajectories_map(map(t, i)), :) == c);
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
                pts_session = [pts_session, pts];
                pos = [pos, d];
                d = d + 0.05;                 
            end                                  
        end
       
        figure;
        boxplot(data./1000, groups, 'positions', pos, 'colors', [0 0 0]);     
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
        end
        set([h], 'LineWidth', 0.8);
                
        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0], 'LineWidth', 2);
        end

        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end        
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        
        set(gca, 'XTickLabel', lbls, 'Ylim', [0, lim(c)/1000], 'FontSize', fontsize);
        set(gca, 'LineWidth', 1.5);   
                 
        ylabel(segments_classification.classes{1,c}{1,2}, 'FontSize', fontsize);
        xlabel('trial', 'FontSize', fontsize);        
        
        set(gcf, 'Color', 'w');
        box off;  
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), sprintf('segment_length_strategy_%d', c));
    end     
end