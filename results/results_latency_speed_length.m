function results_latency_speed_length(segmentation_configs,varargin)
% Comparison of full trajectory metrics for 2 groups of N animals over a 
% set of M trials. The generated plots show:
% 1. The escape latency.
% 2. The average movement speed.
% 3. The average path length.

    latency = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,9);
    length_ = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,10);
    speed = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,11);
    sessions = segmentation_configs.COMMON_SETTINGS{1,2}{1,1}; 
    if isstring(sessions) || ischar(sessions)
        sessions = str2num((sessions));
    elseif iscell(sessions)
        sessions = cell2mat((sessions));
    end 
    trials_per_session = segmentation_configs.COMMON_SETTINGS{1,4}{1,1};
    if isstring(trials_per_session) || ischar(trials_per_session)
        trials_per_session = str2num((trials_per_session));
    elseif iscell(trials_per_session)
        trials_per_session = cell2mat((trials_per_session));
    end 
    total_trials = sum(trials_per_session);
    
    [groups_, animals_ids, animals_trajectories_map] = trajectories_map(segmentation_configs,varargin{:});
    if isempty(animals_trajectories_map)
        return
    end    

    % Equalize groups
    if length(animals_trajectories_map) > 1
        if size(animals_trajectories_map{1,1},2)~=size(animals_trajectories_map{1,2},2)
            if size(animals_trajectories_map{1,1},2) > size(animals_trajectories_map{1,2},2)
                dif = size(animals_trajectories_map{1,1},2) - size(animals_trajectories_map{1,2},2);
                animals_trajectories_map{1,1} = animals_trajectories_map{1,1}(1:end,1:end-dif);
            else    
                dif = size(animals_trajectories_map{1,2},2) - size(animals_trajectories_map{1,1},2);
                animals_trajectories_map{1,2} = animals_trajectories_map{1,2}(1:end,1:end-dif);
            end
        end
    end
    
    vars = [latency' ; speed' ; length_'/100];
    
    %for one group:
    if length(animals_trajectories_map)==1
        one_group_metrics(segmentation_configs,animals_trajectories_map,vars,total_trials,sessions,trials_per_session);
        return
    end    
    
    names = {'latency' , 'speed' , 'length'};
    ylabels = {'latency [s]', 'speed [cm/s]', 'path length [m]'};
    log_y = [0, 0, 0];
    
    for i = 1:size(vars, 1) % for the first trial
        figure;
        values = vars(i, :);
        data = [];
        groups = [];
        xpos = [];
        pos = [0, 0.4, 1.2, 1.6, 2.4, 2.8];
        for s = 1:sessions
            for g = 1:2            
                map = animals_trajectories_map{g};
                ti = (s - 1)*trials_per_session + 1;
                tf = s*trials_per_session;
                tmp = mean(values(map(ti:tf, :)));                 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(s*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(s*2 - 1 + g - 1, 1, length(tmp(:)))];                         
            end
        end
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);
        xtick = 0.2;
        xticks = zeros(1,sessions);
        sess = cell(1,sessions);
        c = 1;
        while xtick < 0.2 + (1.2*sessions)
            xticks(1,c) = xtick;
            xtick = xtick + 1.2;
            sess{1,c} = strcat('session ',num2str(c));
            c = c + 1;
        end
        set(gca, 'XTick', xticks, 'XTickLabel', sess, 'FontSize', 20);         
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [.9 .9 .9], 'FaceAlpha', .3);
        end
        set([h], 'LineWidth', 1.5);        
   
        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end

        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0]);
        end
                
        % check significances
        for s = 1:sessions
            hip = ttest2(data(groups == 2*s - 1), data(groups == 2*s));
            if hip
                h = sigstar( {[pos(2*s - 1), pos(s*2)]}, [0.05]);
                set(h(:, 1), 'LineWidth', 2);
                set(h(:, 2), 'FontSize', 10);
            end
        end
                
        set(gcf, 'Color', 'w');
        set(gca, 'LineWidth', 1.5);
        box off;        
        ylabel(ylabels{i}, 'FontSize', 10);
        export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), sprintf('control_stress_%s', names{i}));
        
        % Do the same for each trial
        clf;
        data = [];
        groups = [];
        xpos = [];
        d = .1;
        idx = 1;
        pos = zeros(1, 2*total_trials);
        for s = 1:sessions
            for t = 1:trials_per_session
                for g = 1:2                    
                    pos(idx) = d;
                    d = d + 0.1;
                    idx = idx + 1;
                end
                d = d + 0.07;
            end
            d = d + 0.15;
        end
        
        % matrix for friedman's multifactor tests
        [animals_trajectories_map,n] = friedman_test(animals_trajectories_map);
        fried = zeros(total_trials*n, 2);                        
        for t = 1:total_trials
            for g = 1:2            
                map = animals_trajectories_map{g};
                tmp = values(map(t, :));                 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(t*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(t*2 - 1 + g - 1, 1, length(tmp(:)))];             
                for j = 1:n
                    fried((t - 1)*n + j, g) = tmp(j);
                end
            end            
        end
                                                   
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);
        set(gca, 'LineWidth', 1.5, 'FontSize', 10);
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
        
        set(gca, 'XLim', [0, max(pos) + 0.1], 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'FontSize', 0.75*10);                 
                
        if log_y(i)
            set (gca, 'Yscale', 'log');
        else
            set (gca, 'Yscale', 'linear');
        end
        
        ylabel(ylabels{i}, 'FontSize', 10);
        xlabel('trial', 'FontSize', 10);

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
        
        % check significances
        for t = 1:total_trials
            p = ranksum(data(groups == 2*t - 1), data(groups == 2*t));                                
            if p < 0.05
                if p < 0.01
                    if p < 0.001
                        alpha = 0.001;
                    else
                        alpha = 0.01;
                    end
                else
                  alpha = 0.05;
                end
            end
        end
                
        set(gcf, 'Color', 'w');
        box off;        
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        export_figure(1, gcf, strcat(segmentation_configs.OUTPUT_DIR,'/'), sprintf('animals_%s', names{i}));
        
        % run friedman test            
        p = friedman(fried, n);
        str = sprintf('Friedman p-value (%s): %g', ylabels{i}, p);
        disp(str);          
    end


end

