function [varargout] = results_strategies_distributions(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,varargin)
% Computes the number of segments for each strategy adopted by two groups
% N animals for a set of M trials.

% DISTRIBUTION:
% 1: Tiago original
% 2: Classification
% 3: Smoothing

    AVERAGE = 0;
    DISTRIBUTION = 3;
    SCRIPTS = 1;
    DISPLAY = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'AVERAGE')
            AVERAGE = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION')
            DISTRIBUTION = varargin{i+1};
        elseif isequal(varargin{i},'SCRIPTS')
            SCRIPTS = varargin{i+1};
        elseif isequal(varargin{i},'DISPLAY')
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
    % Holds number of strategies per trial per animal
    %Trial 1 [animal_1...animel_N] , %Trial 2 [animal_1...animal_N]...  
    mfried_all = cell(1,ncl+1);
    p_mfried = []; %stores the p-values
    % Holds number of strategies per animal per trial
    %Animal 1 [trial_1...trial_N] , %Animal 2 [trial_1...trial_N]...    
    mfriedAnimal_all = cell(1,ncl+1);
    p_mfriedAnimal = []; %stores the p-values
    %Boxplot produces a separate box for each set of data_all values that 
    %share the same groups_all value or values.
    data_all = cell(1,ncl+1);
    groups_all = cell(1,ncl+1);
    %visualization purposes:
    maximum = 0;
    
    for c = 1:ncl+1 %+1 for the Direct Finding (0) class
        data = [];
        groups = [];
        grp = 1;
        % Matrix for friedman's multifactor tests
        nanimals = size(animals_trajectories_map{1,1},2);
        mfried = zeros(nanimals*total_trials, 2); 
        mfriedAnimal = zeros(nanimals*total_trials, 2);
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
                        mfried( (t - 1) * nanimals + i, g) = val;
                        mfriedAnimal( (i - 1) * total_trials + t, g) = val;
                    elseif c > ncl
                        if long_trajectories_map(map(t, i)) == 0
                            pts = [pts, 1];
                            mfried((t - 1)*nanimals + i, g) = 1;
                            mfriedAnimal( (i - 1) * total_trials + t, g) = val;
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
        % Run friedman's test only if we have more than one animal groups
        if length(animals_trajectories_map) > 1
            p = friedman(mfried, nanimals, 'off');
            if c <= ncl
                str = sprintf('%d.Class: %s\tp_frdm: %g', c, segments_classification.classes{1,c}{1,2}, p);    
            else
                str = sprintf('%d.Class: unsegmented\tp_frdm: %g', c, p); 
            end
            if DISPLAY
                disp(str);
            end            
            p_mfried = [p_mfried;p];
            p = friedman(mfriedAnimal, total_trials, 'off');
            if c <= ncl
                str = sprintf('%d.Class: %s\tp_frdm: %g', c, segments_classification.classes{1,c}{1,2}, p);    
            else
                str = sprintf('%d.Class: unsegmented\tp_frdm: %g', c, p); 
            end
            if DISPLAY
                %disp(str);
            end      
            p_mfriedAnimal = [p_mfriedAnimal;p];
        end
        % collect all the data
        data_all{1,c} = data;
        groups_all{1,c} = groups;
        mfried_all{1,c} = mfried;
        mfriedAnimal_all{1,c} = mfriedAnimal; 
        % store maximum data number (for visualization purposes)
        a = max(data);
        if a > maximum
            maximum = a;
        end    
    end     

    extra = (10*maximum)/100; %take the 10% of the maximum
    
    %% Generate figures
    if figures
        % get the configurations from the configs file
        [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
        % arrange each bar of the plot to a certain position
        pos = zeros(1,total_trials*length(animals_trajectories_map));
        pos(1) = 0.05;
        j = 1;
        tmp = 1;
        for i = 2:length(pos)
            if mod(i,2) == 0
                pos(i) = pos(i-1)+0.05; %group = 0.05
            else
                if i == trials_per_session(j)*length(animals_trajectories_map) + tmp
                    pos(i) = pos(i-1)+0.14; %day = 0.14
                    tmp = i;
                    j = j+1; 
                else
                    pos(i) = pos(i-1)+0.07; %trial = 0.07
                end
            end
        end
        
        for c = 1:ncl+1
            f = figure;
            set(f,'Visible','off');
            boxplot(data_all{1,c}, groups_all{1,c}, 'positions', pos, 'colors', [0 0 0]);     
            faxis = findobj(f,'type','axes');
            
            % Box color
            h = findobj(f,'Tag','Box');
            if length(animals_trajectories_map) > 1
                for j=1:2:length(h)
                     patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                end
            else
                for j=1:length(h)
                     patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                end       
            end
            set(h, 'LineWidth', LineWidth);

            % Median
            h = findobj(faxis, 'Tag', 'Median');
            if length(animals_trajectories_map) > 1
                for j=1:2:length(h)
                     line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.8 .8 .8], 'LineWidth', 2);
                end
                for j=2:2:length(h)
                     line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.0 .0 .0], 'LineWidth', 2);
                end
            else
                for j=1:length(h)
                     line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.8 .8 .8], 'LineWidth', 2);
                end                
            end
   
            % Outliers
            h = findobj(faxis, 'Tag', 'Outliers');
            for j=1:length(h)
                set(h(j), 'MarkerEdgeColor', [0 0 0]);
            end      
            
            %Axes
            lbls = {};
            lbls = arrayfun( @(i) sprintf('%d', i), 1:total_trials, 'UniformOutput', 0);     
            if length(animals_trajectories_map) > 1
                set(faxis, 'XTick', (pos(1:2:2*total_trials - 1) + pos(2:2:2*total_trials)) / 2, 'XTickLabel', lbls, 'FontSize', FontSize, 'FontName', FontName);
            else
                set(faxis, 'XTickLabel', lbls, 'Ylim', [0, max(data_all{1,c})+0.5], 'FontSize', FontSize, 'FontName', FontName);
            end
            set(faxis, 'Ylim', [0, max(data_all{1,c})+extra]);
            set(faxis, 'LineWidth', LineWidth);   
            if c <= ncl
                title(segments_classification.classes{1,c}{1,2}, 'FontSize', FontSize, 'FontName', FontName);
            else
                title('Direct Finding', 'FontSize', FontSize, 'FontName', FontName);
            end
            xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
            ylabel('number of class segments', 'FontSize', FontSize, 'FontName', FontName); 

            %Overall
            set(f, 'Color', 'w');
            box off;  
            set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
            %Export and delete
            export_figure(f, output_dir, sprintf('animal_strategy_%d', c), Export, ExportStyle);
            delete(f)
        end    
    end
    
    %% Export figures data
    p_days = {};
    if SCRIPTS
        box_plot_data(nanimals, data_all, groups_all, output_dir);
        if length(animals_trajectories_map) > 1
            p_days = friedman_test_results(p_mfried,p_mfriedAnimal, mfried_all,nanimals,mfriedAnimal_all,trials_per_session,segments_classification.classes,output_dir,varargin{:});
        end
    end
    
    %% Output
    varargout{1} = mfried_all;
    varargout{2} = p_mfried;
    varargout{3} = mfriedAnimal_all;
    varargout{4} = p_mfriedAnimal;
    varargout{5} = data_all;
    varargout{6} = groups_all;
    varargout{7} = pos;
    varargout{8} = p_days;
end

