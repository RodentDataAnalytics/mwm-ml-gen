function [trans,varargout] = animal_transitions(segmentation_configs,classification_configs,varargin)
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
    PROBABILITIES = 0;
    varargout{1} = 0;
    varargout{2} = 0;
    
    % Custom Options
    for i = 1:length(varargin)
        if isequal(varargin{i},'OPTION')
            OPTION = varargin{i+1};
        elseif isequal(varargin{i},'DIVIDE')
            DIVIDE = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION')
            DISTRIBUTION = varargin{i+1};
        elseif isequal(varargin{i},'PROBABILITIES')
            PROBABILITIES = 1;
            groups = varargin{i+1};
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
    
    % Transition probabilities
    if PROBABILITIES
        if length(groups) == 1
            groups = [groups,-1];
        end
        trajectories_groups = arrayfun( @(t) t.group, segmentation_configs.TRAJECTORIES.items);
        nc = classification_configs.CLASSIFICATION.nclasses;
        trans_prob1 = zeros(nc, nc);
        trans_prob2 = zeros(nc, nc);
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
                    if a ~= distr(j) && distr(j) ~= 0 && a ~= 0
                        trans(i) = trans(i) + 1;
                        % probabilities
                        if PROBABILITIES
                            if trajectories_groups(i) == groups(1)
                                trans_prob1(a, distr(j)) = trans_prob1(a, distr(j)) + 1; 
                            elseif trajectories_groups(i) == groups(2)
                                trans_prob2(a, distr(j)) = trans_prob1(a, distr(j)) + 1; 
                            end
                        end
                    end
                    a = distr(j);
                end
                if DIVIDE %divide by the number of segments of the trajectory
                    trans(i) = trans(i)/length(idx);
                end
            end          
        end
        if PROBABILITIES
            % normalize matrices
            trans_prob1 = trans_prob1 ./ repmat(sum(trans_prob1, 2), 1, nc);
            trans_prob2 = trans_prob2 ./ repmat(sum(trans_prob2, 2), 1, nc);
            varargout{1} = trans_prob1;
            varargout{2} = trans_prob2;
            % NaN values
            for i = 1:size(trans_prob1,1)
                for j = 1:size(trans_prob1,2)
                    if isnan(trans_prob1)
                        trans_prob1(i,j) = 0;
                    end
                    if isnan(trans_prob2)
                        trans_prob2(i,j) = 0;
                    end
                end
            end    
            varargout{1} = trans_prob1;
            varargout{2} = trans_prob2;
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