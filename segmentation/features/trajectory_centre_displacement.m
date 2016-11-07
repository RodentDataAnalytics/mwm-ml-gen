function val = trajectory_centre_displacement( traj, values )
    x0 = values(1);
    y0 = values(2);
    r = values(3);
    repr = values(4);
    
    switch repr
        case 0
            [x, y] = trajectory_boundaries(traj.points);
        case 1
            [x, y] = trajectory_boundaries(traj.points, repr);
        otherwise
            error('trajectory_centre_displacement, wrong option')
    end
    
    val = sqrt( (x - x0)^2 + (y - y0)^2) / r;
end