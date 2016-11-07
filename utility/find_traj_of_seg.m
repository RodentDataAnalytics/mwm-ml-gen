function [ traj_id, seg_id ] = find_traj_of_seg( obj, seg_number )
%FIND_TRAJ_OF_SEG returns the trajectory item in which a specific
%segment belongs to. Requires: segments object and segment id.

% Each trajectory has specific attributes that pass to its segments.
% Thus if segments' attributes match trajectory's attributes => that
% segment belongs to this trajectory.

    segment = obj.items(1, seg_number);
    seg_id = segment.segment;
    segment_vector = [segment.session ; segment.group ; segment.id ; segment.trial];
    for i = 1:length(obj.parent.items)
        trajectory = obj.parent.items(1, i);
        trajectory_vector = [trajectory.session ; trajectory.group ; trajectory.id ; trajectory.trial];
        match = segment_vector == trajectory_vector;
        if isempty(find(match == 0)) && isequal(trajectory.track, segment.track);
            traj_id = i;
        end    
    end    
end

