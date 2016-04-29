function val = trajectory_cv_inner_radius(traj, values)
    x0 = values(1);
    y0 = values(2);
    r = values(3);
    
    % need first the centre of the trajectory
    [x0, y0] = trajectory_boundaries(traj.points);
    
    values = [x0,y0,r,0,0];
    res = trajectory_radius(traj, values);    
    values = [x0,y0,r,0,1];
    iqr = trajectory_radius(traj, values);
    
    val = iqr / res;                    
end