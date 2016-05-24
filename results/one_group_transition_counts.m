function one_group_transition_counts(segmentation_configs,classification_configs,groups,total_trials,par,trajectories_,segments_classification)

    fontsize = 12;
    vals = [];
    vals_grps = [];           
    d = 0.05;
    pos = [];            
    ids = {};
    nanimals = -1;
    
    trans = segments_classification.transition_counts_trial(segmentation_configs,classification_configs);
    
    all_trials = arrayfun( @(t) t.trial, trajectories_.items);                   
    all_groups = arrayfun( @(t) t.group, trajectories_.items);                       
    all_groups = all_groups(trajectories_.segmented_index);
    all_trials = all_trials(trajectories_.segmented_index);
                
    ngrp = 0;
    for t = 1:total_trials
        g = 1;                                    
        ngrp = ngrp + 1;
        if t > 1
            ids_grp = ids{g};
        else
            ids_grp = [];
        end

        sel = find(all_trials == t & all_groups == groups(g));

        for i = 1:length(sel)       
            if sel(i) == 0
                continue; % a weird/too short trajectory
            end

            if par(sel(i)) == 0
                 continue;
            end

            val = trans(sel(i));

            vals = [vals, val];
            vals_grps = [vals_grps, ngrp];                        

            id = trajectories_.items(sel(i)).id;        
            id_pos = find(ids_grp == id);
            if length(ids) < g
                ids = [ids, g];
            end

            if isempty(id_pos)
                if g == 1                            
                    if t == 1
                        ids_grp = [ids_grp, id];
                    end
                else
                    if length(ids_grp) < nanimals
                        ids_grp = [ids_grp, id];
                    end
                end
            end                        
        end
        pos = [pos, d];
        d = d + 0.05;
    end

    figure;
    hold off;
    % average each value                        
    boxplot(vals, vals_grps, 'positions', pos, 'colors', [0 0 0]);     
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

    set(gca, 'XTickLabel', lbls, 'Ylim', [0, 25], 'FontSize', fontsize);
    set(gca, 'LineWidth', 1.5);   

    ylabel('transitions', 'FontSize', fontsize);
    xlabel('trial', 'FontSize', 10);        

    set(gcf, 'Color', 'w');
    box off;  
    set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);

    export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), 'transision_counts');
end
