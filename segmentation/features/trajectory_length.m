function len = trajectory_length( traj, values )
%TRAJECTORY_LENGTH Computes length of a trajectory
    tol = values(1);
     
    pts = trajectory_simplify_impl(traj.points, tol);
    len = 0;    
    for i = 2:size(pts, 1)
        % compute the length in cm and seconds
        len = len + norm( pts(i, 2:3) - pts(i-1, 2:3) );        
    end   
end