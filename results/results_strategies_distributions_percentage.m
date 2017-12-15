function [varargout] = results_strategies_distributions_percentage(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,varargin)
% Computes the number of segments for each strategy adopted by two groups
% N animals for a set of M trials.

% DISTRIBUTION:
% 1: Tiago original
% 2: Classification
% 3: Smoothing

    AVERAGE = 0;
    DISTRIBUTION = 3;
    SCRIPTS = 1;

    for i = 1:length(varargin)
        if isequal(varargin{i},'AVERAGE')
            AVERAGE = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION')
            DISTRIBUTION = varargin{i+1};     
        elseif isequal(varargin{i},'SCRIPTS')
            SCRIPTS = varargin{i+1};            
        end
    end
    
    % Get number of trials
    trials_per_session = segmentation_configs.EXPERIMENT_PROPERTIES{30};
    total_trials = sum(trials_per_session);
    % Get classification
    segments_classification = classification_configs.CLASSIFICATION;
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs ); 
    % Number of classification classes
    ncl = segments_classification.nclasses;
    % Strategies distribution
    switch DISTRIBUTION
        case 1
            strat_distr = distr_strategies_gaussian(segmentation_configs, classification_configs);
        case 2
            [strat_distr, ~, ~] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
        case 3
            strat_distr = distr_strategies_smoothing(segmentation_configs, classification_configs,varargin{:});
    end
    
%     for i = 1:size(strat_distr,1)
%         tags = unique(strat_distr);
%         for c = 1:length(tags)
%             tmp = find(strat_distr(i,:) == tags(c));
%             if length(tmp) > 0
%                 if strat_distr(i,tmp(1)) == 2
%                     strat_distr(i,tmp) = 1;
%                 elseif strat_distr(i,tmp(1)) == 3 || strat_distr(i,tmp(1)) == 4 || strat_distr(i,tmp(1)) == 5 || strat_distr(i,tmp(1)) == 6
%                     strat_distr(i,tmp) = 2;
%                 elseif strat_distr(i,tmp(1)) == 7 || strat_distr(i,tmp(1)) == 8
%                     strat_distr(i,tmp) = 3;
%                 end
%             end
%         end
%     end

    % Strategies distribution map
    if AVERAGE
        strat_distr_map = zeros(size(strat_distr,1),segments_classification.nclasses);
        for c = 1:segments_classification.nclasses
            for j = 1:size(strat_distr,1)
                val = length(find(strat_distr(j,:) == c));
                strat_distr_map(j,c) = val;
            end
        end
    end

    % STORAGE
    data_all = cell(1,ncl+1);
    groups_all = cell(1,ncl+1);
    
    for c = 1:ncl+1 %+1 for the Direct Finding (0) class
        data = [];
        groups = [];
        grp = 1;
        % Matrix for friedman's multifactor tests
        nanimals = size(animals_trajectories_map{1,1},2);
        % Iterate over trials
        for t = 1:total_trials
            % Iterate over animal groups
            for g = 1:length(animals_trajectories_map)           
                map = animals_trajectories_map{g};
                pts = [];
                for i = 1:nanimals
                    if long_trajectories_map(map(t, i)) ~= 0                        
                        val = sum(strat_distr(long_trajectories_map(map(t, i)), :) == c);
                        if AVERAGE
                            summ = sum(strat_distr_map(long_trajectories_map(map(t, i)),:));
                            val = val / summ;
                        end
                        pts = [pts, val];
                    elseif c > ncl
                        if long_trajectories_map(map(t, i)) == 0
                            pts = [pts, 1];
                        end
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
            end                    
        end

        % collect all the data
        data_all{1,c} = data;
        groups_all{1,c} = groups;
    end     

    if length(animals_trajectories_map) == 1
        g = 1;
    else
        g = 2;
    end
    maxv = 0;
    % Turn data into percentages
    data_per = cell(1,length(data_all));
    tmp_data_per = zeros(1,2*total_trials);
    for i = 1:length(data_all)
        data_per{i} = tmp_data_per;
    end
    
    % Percentage: group and trial over all strategies (each bar)
    %Doesn't work very well, the difference is not clear
%     for gr = 1:g*total_trials %iterate through trials
%         counter_strategies = zeros(1,length(data_all));
%         for i = 1:length(data_all) %iterate through strategies
%             sel_data = data_all{i};
%             sel_group = groups_all{i};
%             tmp = find(sel_group == gr);
%             counter_strategies(i) = counter_strategies(i) + sum(sel_data(tmp));
%         end
%         for i = 1:length(data_all)
%             sel_data = data_all{i};
%             sel_group = groups_all{i};
%             tmp = find(sel_group == gr); 
%             per = (100*sum(sel_data(tmp))) / sum(counter_strategies);
%             data_per{i}(gr) = per;
%             if max(per) > maxv
%                 maxv = max(per);
%                 extra = 5*maxv / 100;
%             end
%         end
%     end

    % Percentage: divide each bar with the sum of everything
    total_sum = 0;
    for gr = 1:g*total_trials
        total_sum = total_sum + sum(data_all{i});
    end
    for gr = 1:g*total_trials %iterate through trials
        for i = 1:length(data_all)
            sel_data = data_all{i};
            sel_group = groups_all{i};
            tmp = find(sel_group == gr); 
            per = (100*sum(sel_data(tmp))) / total_sum;
            data_per{i}(gr) = per;
            if max(per) > maxv
                maxv = max(per);
                extra = 5*maxv / 100;
            end
        end
    end    
    
    %% Generate figures
    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    if figures
        for c = 1:ncl+1
            f = figure;
            set(f,'Visible','off');
            tmp = data_per{c};
            if g == 1
                ba = bar(tmp, 'LineWidth',1.5);
                set(ba(1),'FaceColor','black');
            else
                tmp = reshape(tmp,[2,length(tmp)/2]);
                ba = bar(tmp', 'LineWidth',1.5);
                set(ba(1),'FaceColor','white');
                set(ba(2),'FaceColor','black');
            end
            
            %Axes
            faxis = findobj(f,'type','axes');
            set(faxis, 'Xlim', [0, total_trials+0.5], 'Ylim', [0, maxv+extra], 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);   
            if c <= ncl
                title(segments_classification.classes{1,c}{1,2}, 'FontSize', FontSize, 'FontName', FontName);
            else
                title('Direct Finding', 'FontSize', FontSize, 'FontName', FontName);
            end
            xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
            ylabel('% of segments', 'FontSize', FontSize, 'FontName', FontName); 

            %Overall
            set(f, 'Color', 'w');
            box off;  
            set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
            %Export and delete
            export_figure(f, output_dir, sprintf('animal_strategy_per_%d', c), Export, ExportStyle);
            delete(f) 
        end    
    end
    
    %% Export figures data
    if SCRIPTS
        bar_plot_data(data_per,output_dir);
    end
    
    %% Output
    varargout{1} = data_per;
end
