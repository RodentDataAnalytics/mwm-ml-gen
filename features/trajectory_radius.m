function res = trajectory_radius(traj, values)
    x0 = values(1);
    y0 = values(2);
    r = values(3);
    tol = values(4);
    option = values(5);
    
    pts = trajectory_simplify_impl(traj.points, tol);                                              
    d = sqrt( power(pts(:, 2) - x0, 2) + power(pts(:, 3) - y0, 2) ) / r;       
    %(d == 0) = 1e-5; % avoid zero-radius
    
    switch option
        case 0
            res = median(d);
        case 1
            res = iqr(d);
        otherwise
            error('trajectory_radius, wrong option')
    end  
   
end    
