function segments = trajectory_segmentation_constant_len( traj, lseg, ovlp, count)
    %SEGMENT_TRAJECTORY Splits the trajectory in segments of length
    % lseg with an overlap of ovlp %
    % Returns an array of instances of the same trajectory class (now repesenting segments)        
    n = size(traj.points, 1);

    % compute cumulative distance vector
    cumdist = zeros(1, n);    
    for i = 2:n
        cumdist(i) = cumdist(i - 1) + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );        
    end

    % step size
    off = lseg*(1. - ovlp);
    % total number of segments - at least 1
    if cumdist(end) > lseg                
        nseg = ceil((cumdist(end) - lseg) / off) + 1;
        off = off + (cumdist(end) - lseg - off*(nseg - 1))/nseg;
    else
        nseg = 1;
    end
    % segments are trajectories again -> construct empty object
    segments = trajectories([]);

    for seg = 0:(nseg - 1)
        starti = 0;
        seg_off = 0;
        pts = [];
        if nseg == 1
            % special case: only 1 segment, don't discard it
            pts = traj.points;
        else
            for i = 1:n
               if cumdist(i) >= seg*off                           
                   if starti == 0
                       starti = i;
                   end
                   if cumdist(i) > (seg*off + lseg)
                       % done we are
                       break;
                   end
                   if isempty(pts)
                       seg_off = cumdist(i);
                   end
                   % otherwise append point to segment
                   pts = [pts; traj.points(i, :)];
               end
            end
        end

        segments = segments.append(...
            trajectory(pts, traj.session, traj.track, traj.group, traj.id, traj.trial, traj.day, seg + 1, seg_off, starti, traj.trial_type, count)...
            );
    end            
end