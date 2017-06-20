function [varargout] = results_latency_speed_length(new_properties,my_trajectories,my_trajectories_features,animals_trajectories_map,figures,output_dir,varargin)
% Comparison of full trajectory metrics for 2 groups of N animals over a 
% set of M trials. The generated plots show:
% 1. The escape latency (sec).
% 2. The average movement speed (cm/sec).
% 3. The average path length (meters).

    SCRIPTS = 1;
    DISPLAY = 1;
    
    % Get features: latency, length, speed
    latency = my_trajectories_features(:,end-2);
    length_ = my_trajectories_features(:,end-1);
    speed = my_trajectories_features(:,end);
    vars = [latency' ; speed' ; length_'/100];
    names = {'escape latency' , 'speed' , 'path length'};
    labels = {'seconds [s]', 'centimeters per second [cm/s]', 'meters [m]'};
    % Get properties: days and trials
    days = new_properties{28}; 
    trials_per_session = new_properties{30};
    total_trials = sum(trials_per_session);
    
    % STORAGE
    % Holds number of strategies per trial per animal
    %Trial 1 [animal_1...animel_N] , %Trial 2 [animal_1...animal_N]...  
    mfried_all = cell(1,size(vars,1));
    p_mfried = []; %stores the p-values
    % Holds number of strategies per animal per trial
    %Animal 1 [trial_1...trial_N] , %Animal 2 [trial_1...trial_N]...    
    mfriedAnimal_all = cell(1,size(vars,1));
    p_mfriedAnimal = []; %stores the p-values
    %Boxplot produces a separate box for each set of data_all values that 
    %share the same groups_all value or values.
    data_all = cell(1,size(vars,1));
    groups_all = cell(1,size(vars,1));
    %visualization purposes:
    maximum = 0;

    for v = 1:size(vars, 1)
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
                    val = vars(v,(map(t, i)));
                    pts = [pts, val];
                    mfried( (t - 1) * nanimals + i, g) = val;
                    mfriedAnimal( (i - 1) * total_trials + t, g) = val;
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
            str = sprintf('%s\tp_frdm: %g', names{v}, p);   
            p_mfried = [p_mfried;p];
            if DISPLAY
                disp(str);
            end            
            p = friedman(mfriedAnimal, total_trials, 'off');
            str = sprintf('%s\tp_frdm: %g', labels{v}, p); 
            p_mfriedAnimal = [p_mfriedAnimal;p];
            if DISPLAY
                %disp(str);
            end      
        end
        % collect all the data
        data_all{1,v} = data;
        groups_all{1,v} = groups;
        mfried_all{1,v} = mfried;
        mfriedAnimal_all{1,v} = mfriedAnimal; 
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
        
        for v = 1:size(vars, 1)
            f = figure;
            set(f,'Visible','off');
            boxplot(data_all{1,v}, groups_all{1,v}, 'positions', pos, 'colors', [0 0 0]);     
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
                set(faxis, 'XTickLabel', lbls, 'Ylim', [0, max(data_all{1,v})+0.5], 'FontSize', FontSize, 'FontName', FontName);
            end
            set(faxis, 'Ylim', [0, max(data_all{1,v})+extra]);
            set(faxis, 'LineWidth', LineWidth);   
            title(names{v}, 'FontSize', FontSize, 'FontName', FontName);
            xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
            ylabel(labels{v}, 'FontSize', FontSize, 'FontName', FontName); 

            %Overall
            set(f, 'Color', 'w');
            box off;  
            set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
            %Export and delete
            export_figure(f, output_dir, sprintf('animals_%s', names{v}), Export, ExportStyle);
            delete(f)
        end    
    end    
    
    %% Export figures data
    p_days = {};
    if SCRIPTS
        box_plot_data(nanimals, data_all, groups_all, output_dir);
        if length(animals_trajectories_map) > 1
            p_days = friedman_test_results(p_mfried,p_mfriedAnimal, mfried_all,nanimals,mfriedAnimal_all,trials_per_session,labels,output_dir,'METRICS',varargin{:});
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

