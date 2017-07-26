function [error,dir_master] = generate_results(project_path, name, my_trajectories, segmentation_configs, classifications, animals_trajectories_map, animals_ids, b_pressed, groups, varargin)
%GENERATE_RESULTS creates results folder tree, forms the final results and
%saves them inside the specific folders
    
    error = 1;
    WAITBAR = 1;
    FIGURES = 1;
    DISTRIBUTION = 3;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'extra_segments')
            extra_segments = varargin{i+1};
            if isempty(extra_segments)
                continue;
            else
                [segmentation_configs, classifications] = include_small_trajectories(extra_segments, segmentation_configs, classifications);
            end
        elseif isequal(varargin{i},'WAITBAR')    
            WAITBAR = varargin{i+1};
        elseif isequal(varargin{i},'FIGURES')    
            FIGURES = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION') 
            DISTRIBUTION = varargin{i+1};
        end        
    end

    [dir_list,dir_master] = build_results_tree(project_path, b_pressed, name, classifications, groups, varargin{:});
    
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

    if WAITBAR
        h = waitbar(0,'Generating results...','Name','Results');
    end
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
    %Strategies distributions
    strat_distr_ = cell(1,length(classifications)); 
    %Time of each interval
    time_per_segment_ = cell(1,length(classifications));
    try
        switch b_pressed
            case 'Transitions'
                for i = 1:length(classifications)
                    [~,p,~,~,vals,vals_grps,pos] = results_transition_counts(segmentation_configs,classifications{i},animals_trajectories_map,FIGURES,dir_list{i},varargin{:});
                    p_{i} = p;
                    vals_{i} = vals;
                    vals_grps_{i} = vals_grps;
                    if WAITBAR
                        waitbar(i/length(classifications)); 
                    end
                end
            case 'Strategies'
                data_per_all = cell(1,length(classifications)); 
                for i = 1:length(classifications)
                    %[mfried_all, p_mfried, mfriedAnimal_all, p_mfriedAnimal, data_all, groups_all, pos, p_days]
                    [~,p,~,~,vals,vals_grps,pos,~,strat_distr,time_per_segment] = results_strategies_distributions(segmentation_configs,classifications{i},animals_trajectories_map,FIGURES,dir_list{i},varargin{:});
                    data_per = results_strategies_distributions_percentage(segmentation_configs,classifications{i},animals_trajectories_map,FIGURES,dir_list{i},varargin{:});
                    data_per_all{i} = data_per;
                    p_{i} = p;
                    vals_{i} = vals;
                    vals_grps_{i} = vals_grps;
                    strat_distr_{i} = strat_distr;
                    time_per_segment_{i} = time_per_segment;
                    if WAITBAR
                        waitbar(i/length(classifications)); 
                    end
                end 
            case 'Probabilities'
                if length(groups) > 1
                    for i = 1:length(classifications)
                        [prob1, prob2] = results_strategies_transition_prob(segmentation_configs,classifications{i},groups,FIGURES,dir_list{i},varargin{:});
                        vals_{i} = {prob1,prob2};
                        if WAITBAR
                            waitbar(i/length(classifications)); 
                        end
                    end
                else
                   for i = 1:length(classifications)
                        [prob1] = results_strategies_transition_prob(segmentation_configs,classifications{i},groups,FIGURES,dir_list{i},varargin{:});
                        vals_{i} = {prob1};
                        if WAITBAR
                            waitbar(i/length(classifications)); 
                        end
                    end
                end  
        end
    catch
        %close all opened files
        fclose('all'); 
        %delete the results directory and the waitbar
        rmdir(dir_master, 's')
        if WAITBAR
            delete(h);
        end
        error_messages(18);
        return
    end
    
    %% Export raw data
    if isequal(b_pressed,'Strategies')
        trajectories_map_csv(my_trajectories,segmentation_configs,animals_trajectories_map,animals_ids,strat_distr_,dir_list);
        if isequal(DISTRIBUTION,3)
            trajectories_map_time_csv(my_trajectories,segmentation_configs,animals_trajectories_map,animals_ids,time_per_segment_,dir_list);
        end
    end
        
    %% Generate a summary of the results
    if WAITBAR
        waitbar(1,h,'Finalizing...');
    end
    %if only 1 iteration was selected no summary needs to be created
    if length(p_) > 1
        total_trials = sum(segmentation_configs.EXPERIMENT_PROPERTIES{30});
        class_tags = classifications{1}.CLASSIFICATION_TAGS;
        switch b_pressed
            case 'Strategies'
                create_average_figure(animals_trajectories_map,vals_,vals_grps_{1},pos,dir_list{end},total_trials,class_tags);
                create_average_figure_per(animals_trajectories_map,data_per_all,dir_list{end},total_trials,class_tags);
            case 'Transitions'
                class_tags = {{'Transitions','Transitions',0,0}};
                create_average_figure(animals_trajectories_map,vals_,vals_grps_{1},pos,dir_list{end},total_trials,class_tags);
            case 'Probabilities'
                fpath = fullfile(dir_list{end},'summary.csv');
                error = create_average_probs(vals_,class_tags,fpath,groups);
                if error
                    error_messages(19);
                end
                if WAITBAR
                    delete(h);
                end
                error = 0;
                return;
        end
        if length(groups) > 1;
            fpath = fullfile(dir_list{end},'pvalues_summary.csv');
            error = create_pvalues_table(p_,class_tags,fpath);
            if error
                error_messages(20);
                if WAITBAR
                    delete(h);
                end
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
    if WAITBAR
        delete(h);
    end
    error = 0;
end
