function results_strategies_distributions_length(segmentation_configs,classification_configs,varargin)
% Computes the average segment lengths for each strategy adopted by 
% two groups of N animals for a set of M trials The generated plots
% show the average length in meters that the animals spent in one strategy 
% during each trial (for S total strategies, were S is defined by the user)

    trials_per_session = segmentation_configs.COMMON_SETTINGS{1,4}{1,1};
    if ischar(trials_per_session)
        trials_per_session = str2num((trials_per_session));
    elseif iscell(trials_per_session)
        trials_per_session = cell2mat((trials_per_session));
    end 
    total_trials = sum(trials_per_session);
    segments_classification = classification_configs.CLASSIFICATION;
    [groups_, animals_ids, animals_trajectories_map] = trajectories_map(segmentation_configs,varargin{:});
    if groups_ == -1
        return
    end    
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs );
    % Strategies distribution
    strat_distr = segments_classification.mapping_ordered(segmentation_configs);
    
    %for one group
    if length(animals_trajectories_map) == 1
        one_group_strategies(segmentation_configs,total_trials,segments_classification,animals_trajectories_map,long_trajectories_map,strat_distr);
        return
    end    
    
    % Equalize groups
    if length(animals_trajectories_map) > 0
        if size(animals_trajectories_map{1,1},2)~=size(animals_trajectories_map{1,2},2)
            % set current GUI visibility to off
            temp = findall(gcf);
            set(temp,'Visible','off');
            % run the other GUI
            features = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,9:11);
            [animals_ids, animals_trajectories_map] = equalize_groups(groups_, animals_ids, animals_trajectories_map, features);
            % resume main GUI visibility
            set(temp,'Visible','on');
            % if Cancel or X was clicked, return
            if size(animals_trajectories_map{1,1},2)~=size(animals_trajectories_map{1,2},2)
                return
            end   
        end
    end
    
    lim = [90, 60, 13, 25, 25, 13, 25, 18]*25;
    
    %% plot distributions
    b = 1;
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
        
        [animals_trajectories_map,nanimals] = friedman_test(animals_trajectories_map);
        mfried = zeros(nanimals*total_trials, 2);                
        
        for t = 1:total_trials
            for g = 1:2            
                tot = 0;
                pts_session = [];
                map = animals_trajectories_map{g};
        
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
            
            if rem(t, 4) == 0
                d = d + 0.07;                
            end                
            d = d + 0.02;                
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
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
        end

        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end        
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        
        set(gca, 'DataAspectRatio', [1, lim(c)*1.25/1000, 1], 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'Ylim', [0, lim(c)/1000], 'FontSize', 0.75*10);
        set(gca, 'LineWidth', 1.5);   
                 
        ylabel(segments_classification.classes{1,c}{1,2}, 'FontSize', 0.75*10);
        xlabel('trial', 'FontSize', 10);        
        
        set(gcf, 'Color', 'w');
        box off;  
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), sprintf('segment_length_strategy_%d', c));
        
        try
            p = friedman(mfried, nanimals);
            str = sprintf('Class: %s\tp_frdm: %g', segments_classification.classes{1,c}{1,2}, p);            
            disp(str);        
        catch
            disp('Error on Friedman test. Friedman test is skipped');
        end    
    end     
end

