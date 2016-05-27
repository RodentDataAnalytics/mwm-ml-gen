function results_transition_counts(segmentation_configs,classification_configs,varargin)
% Computes and presents the number of transitions between strategies 
% for two groups of N animals.
    
    segments_classification = classification_configs.CLASSIFICATION;
    trajectories_ = segmentation_configs.TRAJECTORIES;
    par = segmentation_configs.PARTITION;
    trials_per_session = segmentation_configs.COMMON_SETTINGS{1,4}{1,1};
    if isstring(trials_per_session) || ischar(trials_per_session)
        trials_per_session = sum(str2num((trials_per_session)));
    elseif iscell(trials_per_session)
        trials_per_session = sum(cell2mat((trials_per_session)));
    else
        trials_per_session = sum(trials_per_session);
    end 
    total_trials = sum(trials_per_session);
    groups = arrayfun( @(t) t.group, segmentation_configs.TRAJECTORIES.items);
    
    if length(varargin) > 1 %run from other function
        groups = [varargin{1,1},varargin{1,2}];
    else    
        groups = validate_groups(unique(groups), varargin{:});
    end    
    if groups==-1
        return
    end  
    
    if length(groups) == 1
        one_group_transition_counts(segmentation_configs,classification_configs,groups,total_trials,par,trajectories_,segments_classification);
        return
    end    

    vals = [];
    vals_grps = [];           
    d = 0.05;
    pos = [];            
    ngrp = 0;  
    % for the friedman test
    mfried = [];
    ids = {};
    nanimals = -1;
    
    trans = segments_classification.transition_counts_trial(segmentation_configs,classification_configs);
    
    all_trials = arrayfun( @(t) t.trial, trajectories_.items);                   
    all_groups = arrayfun( @(t) t.group, trajectories_.items);                       
    all_groups = all_groups(trajectories_.segmented_index);
    all_trials = all_trials(trajectories_.segmented_index);
                
    ngrp = 0;
    for t = 1:total_trials
        for g = 1:2                                    
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

                % put it in the matrix for the friedman test
                id = trajectories_.items(sel(i)).id;        
                id_pos = find(ids_grp == id);
                if length(ids) < g
                    ids = [ids, g];
                end

                if isempty(id_pos)
                    if g == 1                            
                        if t == 1
                            ids_grp = [ids_grp, id];
                            id_pos = length(ids_grp);
                        end
                    else
                        if length(ids_grp) < nanimals
                            ids_grp = [ids_grp, id];
                            id_pos = length(ids_grp);
                        end
                    end
                end                        
                if ~isempty(id_pos)
                    assert((nanimals == -1 && t == 1) || id_pos <= nanimals);
                    mfried( (t - 1)*nanimals + id_pos, g) = val;
                end
            end
            ids{g} = ids_grp;
            if t == 1 && g == 1
                nanimals = length(ids_grp);
                % now we know the size of the end matrix
                tmp = zeros(nanimals*total_trials, 2);
                tmp(1:nanimals, 1) = mfried;
                mfried = tmp;
            end
            pos = [pos, d];
            d = d + 0.05;
        end
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
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
    end

    h = findobj(gca, 'Tag', 'Outliers');
    for j=1:length(h)
        set(h(j), 'MarkerEdgeColor', [0 0 0]);
    end        

    lbls = {};
    lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     

    set(gca, 'DataAspectRatio', [1, 25*1.25, 1], 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'Ylim', [0, 25], 'FontSize', 0.75*10);
    set(gca, 'LineWidth', 1.5);   

    ylabel('transitions', 'FontSize', 0.75*10);
    xlabel('trial', 'FontSize', 10);        

    set(gcf, 'Color', 'w');
    box off;  
    set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);

    export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), 'transision_counts');

    p = friedman(mfried, nanimals, 'off');
    str = sprintf('p_frdm: %g', p);            
    disp(str);
    
    p = anova2(mfried, nanimals, 'off');
    str = sprintf('p_anova: %g', p);            
    disp(str);
