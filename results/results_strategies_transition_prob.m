function varargout = results_strategies_transition_prob(segmentation_configs,classification_configs,groups,figures,output_dir,varargin)
% Transition probabilities of strategies within trials for two groups of
% N animals. Rows and columns indicate the starting and ending strategies 
% respectively. Row values are normalised.

    % Get classification
    segments_classification = classification_configs.CLASSIFICATION;
    
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories( segmentation_configs );
    
    % Strategies distribution
    %[strat_distr, ~, ~, ~] = distr_strategies(segmentation_configs, classification_configs);
    strat_distr = distr_strategies_gaussian(segmentation_configs, classification_configs);
    
    count = length(segmentation_configs.TRAJECTORIES.items);
    partitions = segmentation_configs.PARTITION;
    % Select group(s) specified by the user
    trajectories_groups = arrayfun( @(t) t.group, segmentation_configs.TRAJECTORIES.items);

    % Create matrices
    if length(groups) == 1
        nc = segments_classification.nclasses;
        trans_prob1 = zeros(nc, nc);
    else
        nc = segments_classification.nclasses;
        trans_prob1 = zeros(nc, nc);
        trans_prob2 = zeros(nc, nc);
    end

    traj_idx = 1;
    nseg = 0;
    prev_class = -1;
    while traj_idx <= count
        if nseg >= partitions(traj_idx)
            traj_idx = traj_idx + 1;
            nseg = 0;
            prev_class = -1;
            continue;
        end       
        nseg = nseg + 1;
 
        new_class = strat_distr(long_trajectories_map(traj_idx), nseg);
        
        % for two groups
        if length(groups) ~= 1
            if prev_class == -1
                prev_class = new_class;
            elseif prev_class ~= new_class    
                % we have a transition
                if new_class > 0 && prev_class > 0
                    if trajectories_groups(traj_idx) == groups(1)                    
                        trans_prob1(prev_class, new_class) = trans_prob1(prev_class, new_class) + 1; 
                    else
                        trans_prob2(prev_class, new_class) = trans_prob2(prev_class, new_class) + 1; 
                    end  
                end
                new_class = prev_class;
            end  
        % for one group
        else
            if prev_class == -1
                prev_class = new_class;
            elseif prev_class ~= new_class
                % we have a transition
                if new_class > 0 && prev_class > 0
                    if trajectories_groups(traj_idx) == groups(1)                    
                        trans_prob1(prev_class, new_class) = trans_prob1(prev_class, new_class) + 1; 
                    end
                end    
                new_class = prev_class;
            end  
        end 
    end
    % normalize matrices
    if length(groups) ~= 1
        trans_prob1 = trans_prob1 ./ repmat(sum(trans_prob1, 2), 1, nc);
        trans_prob2 = trans_prob2 ./ repmat(sum(trans_prob2, 2), 1, nc);
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
    else
        trans_prob1 = trans_prob1 ./ repmat(sum(trans_prob1, 2), 1, nc);
        % NaN values
        for i = 1:size(trans_prob1,1)
            for j = 1:size(trans_prob1,2)
                if isnan(trans_prob1)
                    trans_prob1(i,j) = 0;
                end
            end
        end
        varargout{1} = trans_prob1;
    end
    
%     for i = 1:segments_classification.nclasses
%         fprintf('\nClass %d: %s', i, segments_classification.classes{1,i}{1,2});
%     end
%     fn = fullfile(output_dir, 'trans_prob.mat');
%     if length(groups) ~= 1
%         save(fn, 'trans_prob1','trans_prob2');
%         trans_prob1
%         trans_prob2 
%     else
%         save(fn, 'trans_prob1');
%         trans_prob1
%     end    
    
    % save to txt
    fn2 = fullfile(output_dir, 'transition_probabilities.txt');
    fileID = fopen(fn2,'wt');
    for i = 1:segments_classification.nclasses
        fprintf(fileID,'%d. %s\n', i, segments_classification.classes{1,i}{1,2});
    end
    
    fprintf(fileID, '\n');
    if length(groups) ~= 1
        for i=1:size(trans_prob1,1)
            fprintf(fileID, '%6.4f ', trans_prob1(i,:));
            fprintf(fileID, '\n');
        end
        fprintf(fileID, '\n');
        for i=1:size(trans_prob2,1)
            fprintf(fileID, '%6.4f ', trans_prob2(i,:));
            fprintf(fileID, '\n');
        end      
    else
        for i=1:size(trans_prob1,1)
            fprintf(fileID, '%6.4f ', trans_prob1(i,:));
            fprintf(fileID, '\n');
        end
    end   
    fclose(fileID);  
end

