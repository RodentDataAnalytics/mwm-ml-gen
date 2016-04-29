function f = trajectory_focus( traj, values )        
    % the focus is computed based on the area of the circle with
    % perimeter = trajectory length 
    x0 = values(1);
    y0 = values(2);
    tol = values(3);
        
    [~, ~, a, b] = trajectory_boundaries(traj.points);
    f = 1 - a*b/(trajectory_length(traj, tol)^2 / (4*pi));    
end