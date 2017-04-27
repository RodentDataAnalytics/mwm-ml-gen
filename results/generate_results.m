function error = generate_results(project_path, name, segmentation_configs, classifications, animals_trajectories_map, b_pressed, groups, varargin)
%GENERATE_RESULTS creates results folder tree, forms the final results and
%saves them inside the specific folders
    
    error = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'extra_segments')
            extra_segments = varargin{i+1};
            if isempty(extra_segments)
                break;
            end
            trajs = extra_segments{1};
            labs = extra_segments{2};
            labs = labs(:,1);
            [trajs,idx] = sort(trajs);
            labs = labs(idx);
            tag_id = -1;
            for t = 1:length(trajs)
                for l = 1:length(classifications{1}.CLASSIFICATION_TAGS)
                    if isequal(classifications{1}.CLASSIFICATION_TAGS{l}{1},labs{t})
                        tag_id = classifications{1}.CLASSIFICATION_TAGS{l}{3};
                    end
                end
                if tag_id == -1
                    continue;
                end
                % Make a new segment
                tmp = segmentation_configs.TRAJECTORIES.items(1,trajs(t));
                pts = tmp.points;
                session = tmp.session;
                track = tmp.track;
                group = tmp.trial;
                id = tmp.id;
                trial = tmp.trial;
                day = tmp.day;
                segment = 1;
                off = 0;
                starti = 0;
                trial_type = tmp.trial_type;
                traj_num = tmp.traj_num;
                new_traj = trajectory(pts, session, track, group, id, trial, day, segment, off, starti, trial_type, traj_num);
                % Change segmentation_configs and classification_configs
                segmentation_configs.PARTITION(trajs(t)) = 1;
                feats = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(trajs(t),:);
                if trajs(t) == 1 %if it is the first trajectory
                    segmentation_configs.SEGMENTS.items = [new_traj, segmentation_configs.SEGMENTS.items];
                    segmentation_configs.FEATURES_VALUES_SEGMENTS = [feats ; segmentation_configs.FEATURES_VALUES_SEGMENTS];
                    classifications{i}.CLASSIFICATION.class_map = [tag_id, classifications{i}.CLASSIFICATION.class_map];
                elseif trajs(t) == length(segmentation_configs.PARTITION); %if it is the last trajectory
                    segmentation_configs.SEGMENTS.items = [segmentation_configs.SEGMENTS.items, new_traj];
                    segmentation_configs.FEATURES_VALUES_SEGMENTS = [segmentation_configs.FEATURES_VALUES_SEGMENTS; feats];
                    classifications{i}.CLASSIFICATION.class_map = [classifications{i}.CLASSIFICATION.class_map, tag_id];
                else %put it in the correct slot
                    prev_tag = trajs(t) - 1;
                    %s+1 is the slot where the new element needs to be placed
                    s = sum(segmentation_configs.PARTITION(1:prev_tag));
                    disp(s);
                    %put another slot in the arrays
                    segmentation_configs.SEGMENTS.items = [segmentation_configs.SEGMENTS.items, new_traj];
                    segmentation_configs.FEATURES_VALUES_SEGMENTS = [segmentation_configs.FEATURES_VALUES_SEGMENTS; feats];
                    classifications{i}.CLASSIFICATION.class_map = [classifications{i}.CLASSIFICATION.class_map, tag_id];
                    %swift last-1 element to the right until the slot we need to place the new element
                    for iter = length(segmentation_configs.SEGMENTS.items)-1 : -1 : s+1
                        segmentation_configs.SEGMENTS.items(iter+1) = segmentation_configs.SEGMENTS.items(iter);
                        segmentation_configs.FEATURES_VALUES_SEGMENTS(iter+1,:) = segmentation_configs.FEATURES_VALUES_SEGMENTS(iter,:);
                        classifications{i}.CLASSIFICATION.class_map(iter+1) = classifications{i}.CLASSIFICATION.class_map(iter);
                    end
                    %put the new element to the slot
                    segmentation_configs.SEGMENTS.items(s+1) = new_traj;
                    segmentation_configs.FEATURES_VALUES_SEGMENTS(s+1,:) = feats;
                    classifications{i}.CLASSIFICATION.class_map(s+1) = tag_id;
                end
                classifications{i}.FEATURES = segmentation_configs.FEATURES_VALUES_SEGMENTS; 
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
        errordlg('Selected classification and segmentation do not match','Error');
        return
    end

    h = waitbar(0,'Generating results...','Name','Results');
    % Variables of interest:
    %Friedman's test p-value (-1 if it is skipped)
    p_ = cell(1,length(classifications));
    p_trial = cell(1,length(classifications));
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
                if length(groups) > 1
                    for i = 1:length(classifications)
                        [p,mfried,nanimals,vals,vals_grps,pos] = results_transition_counts(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                        p_{i} = p;
                        mfried_{i} = mfried;
                        nanimals_{i} = nanimals;
                        vals_{i} = vals;
                        vals_grps_{i} = vals_grps;
                        pos_{i} = pos;
                        waitbar(i/length(classifications)); 
                    end
                else
                   for i = 1:length(classifications)
                        [vals,vals_grps,pos] = results_transition_counts(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                        vals_{i} = vals;
                        vals_grps_{i} = vals_grps;
                        pos_{i} = pos;
                        waitbar(i/length(classifications)); 
                    end
                end
            case 'Strategies'
                 if length(groups) > 1
                    for i = 1:length(classifications)
                        %[p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions_length(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                        [p,mfried,nanimals,vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                        %p_t = results_avg_strategies_trial(segmentation_configs,classifications{i},mfried,nanimals,dir_list{i});
                        %p_trial{i} = p_t;
                        p_{i} = p;
                        mfried_{i} = mfried;
                        nanimals_{i} = nanimals;
                        vals_{i} = vals;
                        vals_grps_{i} = vals_grps;
                        pos_{i} = pos;
                        waitbar(i/length(classifications)); 
                    end
                else
                   for i = 1:length(classifications)
                        [vals,vals_grps,pos] = results_strategies_distributions(segmentation_configs,classifications{i},animals_trajectories_map,1,dir_list{i});
                        vals_{i} = vals;
                        vals_grps_{i} = vals_grps;
                        pos_{i} = pos;
                        waitbar(i/length(classifications)); 
                    end
                 end 
            case 'Probabilities'
                if length(groups) > 1
                    for i = 1:length(classifications)
                        [prob1, prob2] = results_strategies_transition_prob(segmentation_configs,classifications{i},groups,1,dir_list{i});
                        vals_{i} = {prob1,prob2};
                        waitbar(i/length(classifications)); 
                    end
                else
                   for i = 1:length(classifications)
                        [prob1] = results_strategies_transition_prob(segmentation_configs,classifications{i},groups,1,dir_list{i});
                        vals_{i} = {prob1};
                        waitbar(i/length(classifications)); 
                    end
                end  
        end
    catch
        a = fopen('all'); %close all opened files
        for i = 1:length(a)
            fclose(a(i));
        end
        %delete the results directory and the waitbar
        rmdir(dir_master, 's')
        delete(h);
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
                create_average_figure(vals_,vals_grps_{1},pos_{1},dir_list{end},total_trials,class_tags);
            case 'Transitions'
                class_tags = {{'Transitions','Transitions',0,0}};
                create_average_figure(vals_,vals_grps_,pos_,dir_list{end},total_trials,class_tags);
            case 'Probabilities'
                fpath = fullfile(dir_list{end},'summary.csv');
                error = create_average_probs(vals_,class_tags,fpath,groups);
                if error
                    errordlg('Could not create summary file');
                end
                delete(h);
                error = 0;
                return;
        end
        if length(groups) > 1;
            fpath = fullfile(dir_list{end},'pvalues_summary.csv');
            error = create_pvalues_table(p_,class_tags,fpath);
            if error
                errordlg('Could not create p-values summary file');
                return
            end
%             fpath = fullfile(dir_list{end},'pvalues_trial_summary.csv');
%             error = create_pvalues_table(p_trial,class_tags,fpath,'trial',1);
%             if error
%                 errordlg('Could not create p-values (trial) summary file');
%                 return
%             end
            switch b_pressed
                case 'Strategies'
                    error = create_pvalues_figure(p_,class_tags,dir_list{end});
                    %error = create_pvalues_figure(p_trial,class_tags,dir_list{end},'trial',1);
                case 'Transitions'    
                    error = create_pvalues_figure(p_,class_tags,dir_list{end},'tag',{''},'xlabel','transitions');
            end
            if error
                errordlg('Cannot create summary p-values figure');
            end
        end
    end
    delete(h);
    error = 0;
end

