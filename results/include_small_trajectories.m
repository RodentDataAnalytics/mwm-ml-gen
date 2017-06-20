function [segmentation_configs, classifications] = include_small_trajectories(extra_segments, segmentation_configs, classifications)
%INCLUDE_SMALL_TRAJECTORIES chnage the objects and add the new segments

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
            for i = 1:length(classifications)
                classifications{i}.CLASSIFICATION.class_map = [tag_id, classifications{i}.CLASSIFICATION.class_map];
            end
        elseif trajs(t) == length(segmentation_configs.PARTITION); %if it is the last trajectory
            segmentation_configs.SEGMENTS.items = [segmentation_configs.SEGMENTS.items, new_traj];
            segmentation_configs.FEATURES_VALUES_SEGMENTS = [segmentation_configs.FEATURES_VALUES_SEGMENTS; feats];
            for i = 1:length(classifications)
                classifications{i}.CLASSIFICATION.class_map = [classifications{i}.CLASSIFICATION.class_map, tag_id];
            end
        else %put it in the correct slot
            prev_tag = trajs(t) - 1;
            %s+1 is the slot where the new element needs to be placed
            s = sum(segmentation_configs.PARTITION(1:prev_tag));
            disp(s);
            %put another slot in the arrays
            segmentation_configs.SEGMENTS.items = [segmentation_configs.SEGMENTS.items, new_traj];
            segmentation_configs.FEATURES_VALUES_SEGMENTS = [segmentation_configs.FEATURES_VALUES_SEGMENTS; feats];
            %classifications{i}.CLASSIFICATION.class_map = [classifications{i}.CLASSIFICATION.class_map, tag_id];
            %swift last-1 element to the right until the slot we need to place the new element
            for iter = length(segmentation_configs.SEGMENTS.items)-1 : -1 : s+1
                segmentation_configs.SEGMENTS.items(iter+1) = segmentation_configs.SEGMENTS.items(iter);
                segmentation_configs.FEATURES_VALUES_SEGMENTS(iter+1,:) = segmentation_configs.FEATURES_VALUES_SEGMENTS(iter,:);
                for i = 1:length(classifications)
                    classifications{i}.CLASSIFICATION.class_map(iter+1) = classifications{i}.CLASSIFICATION.class_map(iter);
                end
            end
            %put the new element to the slot
            segmentation_configs.SEGMENTS.items(s+1) = new_traj;
            segmentation_configs.FEATURES_VALUES_SEGMENTS(s+1,:) = feats;
            for i = 1:length(classifications)
                classifications{i}.CLASSIFICATION.class_map(s+1) = tag_id;
            end
        end
        for i = 1:length(classifications) 
            classifications{i}.FEATURES = segmentation_configs.FEATURES_VALUES_SEGMENTS; 
        end
    end
end

