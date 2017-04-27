function trans = animal_transitions(segmentation_configs,classification_configs,varargin)
%ANIMAL_TRANSITIONS computes the transitions occured within each trajectory
%   Return a vector with the number of transitions per trajectory.
%   Trajectories with no segments will have 0 transitions.
%   Undefined segments won't count as transitions

% DISTRIBUTION:
% 1: Tiago original
% 2: Classification
% 3: Smoothing

    %% INITIALIZE %%
    
    % Default Options
    OPTION = 1;
    DIVIDE = 0;
    DISTRIBUTION = 3;
    
    % Custom Options
    for i = 1:length(varargin)
        if isequal(varargin{i},'OPTION')
            OPTION = varargin{i+1};
        elseif isequal(varargin{i},'DIVIDE')
            DIVIDE = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION')
            DISTRIBUTION = varargin{i+1};
        end
    end
    % Strategies distribution
    switch DISTRIBUTION
        case 1
            strat_distr = distr_strategies_gaussian(segmentation_configs, classification_configs);
        case 2
            [strat_distr, ~, ~] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
        case 3
            strat_distr = distr_strategies_smoothing(segmentation_configs, classification_configs,varargin{:});
    end
    
    %% EXECUTE %%
    
%--Option 1--%    
    if OPTION == 1 % Count every transition
        trans = zeros(1,length(segmentation_configs.PARTITION));
        k = 1;
        for i = 1:length(segmentation_configs.PARTITION)
            if segmentation_configs.PARTITION(i) > 0
                distr = strat_distr(k,:);
                k = k + 1;
                idx = find(distr > -1);
                a = distr(1);
                for j = 2:length(idx)
                    if a ~= distr(j) && distr(j) ~= 0;
                        trans(i) = trans(i) + 1;
                    end
                    a = distr(j);
                end
                if DIVIDE %divide by the number of segments of the trajectory
                    trans(i) = trans(i)/length(idx);
                end
            end          
        end
        
%--Option 2--%         
    elseif OPTION == 2 % TT,TT,IC,TT -> 2/4 + 1/4 + 1/4  
        trans = zeros(1,length(segmentation_configs.PARTITION));
        k = 1;
        for i = 1:length(segmentation_configs.PARTITION)
            if segmentation_configs.PARTITION(i) > 0
                distr = strat_distr(k,:);
                k = k + 1;
                idx = find(distr > -1);
                pointer = 1;
                a = distr(1);
                for j = 2:length(idx)
                    if a ~= distr(j) && distr(j) ~= 0;
                        trans(i) = trans(i) + pointer/length(idx);
                        pointer = 1;
                    end
                    a = distr(j);
                    pointer = pointer+1;
                end
                if DIVIDE %divide by the number of segments of the trajectory
                    trans(i) = trans(i)/length(idx);
                end
            end          
        end   
        
%--Option 3--%             
    elseif OPTION == 3 % same as 1 but count transition if next strategy has major weight
        tags = length(classification_configs.CLASSIFICATION_TAGS);
        w = class_weights(strat_distr,length_map,tags); % Tiago's weights
        w = hard_bounds(w); % set min-max weights (min = 1)
        trans = zeros(1,length(segmentation_configs.PARTITION));
        k = 1;
        for i = 1:length(segmentation_configs.PARTITION)
            if segmentation_configs.PARTITION(i) > 0
                distr = strat_distr(k,:);
                k = k + 1;
                idx = find(distr > -1);
                a = distr(1);
                for j = 2:length(idx)
                    if a ~= distr(j) && distr(j) ~= 0
                        if w(distr(j)) > 1 
                            trans(i) = trans(i) + 1;
                        end
                    end
                    a = distr(j);
                end
                if DIVIDE %divide by the number of segments of the trajectory
                    trans(i) = trans(i)/length(idx);
                end
            end          
        end    
    
%--Option 4--%             
    elseif OPTION == 4 % same as 3 but count transition if next strategy has minor weight
        tags = length(classification_configs.CLASSIFICATION_TAGS);
        w = class_weights(strat_distr,length_map,tags); % Tiago's weights
        w = hard_bounds(w); % set min-max weights (min = 1)
        trans = zeros(1,length(segmentation_configs.PARTITION));
        k = 1;
        for i = 1:length(segmentation_configs.PARTITION)
            if segmentation_configs.PARTITION(i) > 0
                distr = strat_distr(k,:);
                k = k + 1;
                idx = find(distr > -1);
                a = distr(1);
                for j = 2:length(idx)
                    if a ~= distr(j) && distr(j) ~= 0
                        if w(distr(j)) == 1 
                            trans(i) = trans(i) + 1;
                        end
                    end
                    a = distr(j);
                end
                if DIVIDE %divide by the number of segments of the trajectory
                    trans(i) = trans(i)/length(idx);
                end
            end          
        end
        
%--Option 5--%         
    elseif OPTION == 5
        [strat_distr,~,~] = strategies_distribution(segmentation_configs,classification_configs,varargin{:}); 
        trans = zeros(1,length(segmentation_configs.PARTITION));
        k = 1;
        for i = 1:length(segmentation_configs.PARTITION)
            if segmentation_configs.PARTITION(i) > 0
                distr = strat_distr(k,:);
                k = k + 1;
                idx = find(distr > -1);
                a = distr(1);
                for j = 2:length(idx)
                    if a ~= distr(j) && distr(j) ~= 0;
                        trans(i) = trans(i) + 1;
                    end
                    a = distr(j);
                end
                if DIVIDE %divide by the number of segments of the trajectory
                    trans(i) = trans(i)/length(idx);
                end
            end          
        end    
    end
end