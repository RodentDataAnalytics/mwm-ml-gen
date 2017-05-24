function [error,dir_master] = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups, varargin)
%GENERATE_RESULTS creates results folder tree, forms the final results and
%saves them inside the specific folders
    
    error = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'extra_segments')
            extra_segments = varargin{i+1};
            if isempty(extra_segments)
                continue;
            else
                [segmentation_configs, classifications] = include_small_trajectories(extra_segments, segmentation_configs, classifications);
            end
        end
    end

    [dir_list,dir_master] = build_results_tree(project_path, b_pressed, name, length(classifications), groups);
    
    % Check if segmentation and classification have the same segments
    segs = size(segmentation_configs.FEATURES_VALUES_SEGMENTS,1);
    try
        segs_ = size(classifications{1}.FEATURES,1);
    catch
        segs_ = size(classifications.FEATURES,1);
    end
    if segs ~= segs_
        error_messages(17)
        return
    end

    h = waitbar(0,'Generating results...','Name','Results');
    % Variables of interest:
    %Friedman's test p-value (-1 if it is skipped)
    p_ = cell(1,length(classifications));
    %Friedman's test sample data
    mfried_ = cell(1,length(classifications));
    %Friedman's test num of replicates per cell
    nanimals_ = cell(1,length(classifications));
    %Input data (vector)
    vals_ = cell(1,length(classifications)); 
    %Grouping variable (length(x))
    vals_grps_ = cell(1,length(classifications)); 
    %Position of each boxplot in the figure  
    pos_ = cell(1,length(classifications)); 
    try
        switch b_pressed
            case 'Transitions'
                for i = 1:length(classifications)
                    [~,p,~,~,vals,vals_grps,pos] = results_transition_counts(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i},varargin{:});
                    p_{i} = p;
                    vals_{i} = vals;
                    vals_grps_{i} = vals_grps;
                    waitbar(i/length(classifications)); 
                end
            case 'Strategies'
                for i = 1:length(classifications)
                    %[p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions_length(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                    %[mfried_all, p_mfried, mfriedAnimal_all, p_mfriedAnimal, data_all, groups_all, pos, p_days]
                    [~,p,~,~,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i},varargin{:});
                    p_{i} = p;
                    vals_{i} = vals;
                    vals_grps_{i} = vals_grps;
                    waitbar(i/length(classifications)); 
                end 
            case 'Probabilities'
                if length(groups) > 1
                    for i = 1:length(classifications)
                        [prob1, prob2] = results_strategies_transition_prob(segmentation_configs,classifications{i},groups,1,dir_list{i},varargin{:});
                        vals_{i} = {prob1,prob2};
                        waitbar(i/length(classifications)); 
                    end
                else
                   for i = 1:length(classifications)
                        [prob1] = results_strategies_transition_prob(segmentation_configs,classifications{i},groups,1,dir_list{i},varargin{:});
                        vals_{i} = {prob1};
                        waitbar(i/length(classifications)); 
                    end
                end  
        end
    catch
        %close all opened files
        fclose('all'); 
        %delete the results directory and the waitbar
        rmdir(dir_master, 's')
        delete(h);
        error_messages(18);
        return
    end
        
    %% Generate a summary of the results
    waitbar(1,h,'Finalizing...');
    %if only 1 iteration was selected no summary needs to be created
    if length(p_) > 1
        total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
        class_tags = classifications{1}.CLASSIFICATION_TAGS;
        switch b_pressed
            case 'Strategies'
                create_average_figure(animals_trajectories_map,vals_,vals_grps_{1},pos,dir_list{end},total_trials,class_tags);
            case 'Transitions'
                class_tags = {{'Transitions','Transitions',0,0}};
                create_average_figure(animals_trajectories_map,vals_,vals_grps_{1},pos_,dir_list{end},total_trials,class_tags);
            case 'Probabilities'
                fpath = fullfile(dir_list{end},'summary.csv');
                error = create_average_probs(vals_,class_tags,fpath,groups);
                if error
                    error_messages(19);
                end
                delete(h);
                error = 0;
                return;
        end
        if length(groups) > 1;
            fpath = fullfile(dir_list{end},'pvalues_summary.csv');
            error = create_pvalues_table(p_,class_tags,fpath);
            if error
                error_messages(20);
                delete(h);
                return
            end
            switch b_pressed
                case 'Strategies'
                    error = create_pvalues_figure(p_,class_tags,dir_list{end});
                case 'Transitions'    
                    error = create_pvalues_figure(p_,class_tags,dir_list{end},'tag',{''},'xlabel','transitions');
            end
            if error
                error_messages(21);
            end
        end
    end
    delete(h);
    error = 0;
end

