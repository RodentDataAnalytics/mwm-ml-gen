function [varargout] = results_transition_counts(segmentation_configs,classification_configs,animals_trajectories_map,figures,output_dir,varargin)
% Computes and presents the number of transitions between strategies 
% for two groups of N animals.
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
    % Get the transitions
    trans = animal_transitions(segmentation_configs,classification_configs,varargin{:});
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs );

    % STORAGE
    % Holds number of strategies per trial per animal
    %Trial 1 [animal_1...animel_N] , %Trial 2 [animal_1...animal_N]...  
    mfried_all = cell(1,1);
    p_mfried = []; %stores the p-values
    % Holds number of strategies per animal per trial
    %Animal 1 [trial_1...trial_N] , %Animal 2 [trial_1...trial_N]...    
    mfriedAnimal_all = cell(1,1);
    p_mfriedAnimal = []; %stores the p-values
    %Boxplot produces a separate box for each set of data_all values that 
    %share the same groups_all value or values.
    data_all = cell(1,1);
    groups_all = cell(1,1);
    
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
                    val = trans(map(t,i));
                    pts = [pts, val];
                    mfried( (t - 1) * nanimals + i, g) = val;
                    mfriedAnimal( (i - 1) * total_trials + t, g) = val;   
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
        str = sprintf('Transitions: \tp_frdm: %g', p);
        if DISPLAY
            disp(str);
        end            
        p_mfried = [p_mfried;p];
        p = friedman(mfriedAnimal, total_trials, 'off');
        str = sprintf('Transitions: \tp_frdm: %g', p);
        if DISPLAY
            %disp(str);
        end      
        p_mfriedAnimal = [p_mfriedAnimal;p];
    end
    % collect all the data
    data_all{1,1} = data;
    groups_all{1,1} = groups;
    mfried_all{1,1} = mfried;
    mfriedAnimal_all{1,1} = mfriedAnimal; 
    
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
        
        f = figure;
        set(f,'Visible','off');
        boxplot(data_all{1,1}, groups_all{1,1}, 'positions', pos, 'colors', [0 0 0]);     
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
            set(faxis, 'XTickLabel', lbls, 'Ylim', [0, max(data_all{1,1})+0.5], 'FontSize', FontSize, 'FontName', FontName);
        end
        set(faxis, 'Ylim', [0, max(data_all{1,1}+10/100*max(data_all{1,1}))]);
        set(faxis, 'LineWidth', LineWidth);  
        title('transitions', 'FontSize', FontSize, 'FontName', FontName)
        xlabel('trials', 'FontSize', FontSize, 'FontName', FontName); 
        ylabel('number of transitions', 'FontSize', FontSize, 'FontName', FontName); 

        %Overall
        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        %Export and delete
        export_figure(f, output_dir, 'transition_counts', Export, ExportStyle);
        delete(f)
    end    
    
    %% Export figures data
    if SCRIPTS
        box_plot_data(nanimals, data_all, groups_all, output_dir);
        if length(animals_trajectories_map) > 1
            friedman_test_results(p_mfried,p_mfriedAnimal, mfried_all,nanimals,mfriedAnimal_all,trials_per_session,'Transitions',output_dir,varargin{:});
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
end
    
