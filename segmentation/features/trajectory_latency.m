function lat = trajectory_latency( traj )
    if size(traj.points, 1) > 0
        lat = traj.points(end, 1) - traj.points(1, 1);
    else
        lat = 0;
    end
end