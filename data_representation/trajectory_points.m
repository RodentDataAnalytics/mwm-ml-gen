function pts = trajectory_points( traj, varargin )
    [tol] = process_options(varargin, 'SimplificationTolerance', 0);
    
    pts = traj.simplify(tol);
end