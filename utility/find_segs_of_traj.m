function [ indexes ] = find_segs_of_traj( obj, traj_number )
%FIND_SEGS_OF_TRAJ returns the segment items that belong to a specific
%trajectory. Requires: segments object and trajectory id.

% Each trajectory has specific attributes that pass to its segments.
% Thus if segments' attributes match trajectory's attributes => that
% segment belongs to this trajectory.

    parent = obj.parent.items(1, traj_number);
    parent_vector = [parent.session ; parent.group ; parent.id ; parent.trial];
    indexes = {};
    k=1;
    for i = 1:length(obj.items)
        segment = obj.items(1, i);
        segment_vector = [segment.session ; segment.group ; segment.id ; segment.trial];
        match = parent_vector == segment_vector;
        if isempty(find(match == 0)) && isequal(parent.track, segment.track);
            indexes{k} = i;
            k=k+1;
        %else
            %break; % from now on the rest of the segs belong to other trajectories
        end    
    end    
    indexes = cell2mat(indexes);
end

