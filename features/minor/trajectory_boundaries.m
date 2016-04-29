function [ x, y, a, b, inc ] = trajectory_boundaries( traj )
    x = 0;
    y = 0;
    a = 0;    
    b = 0;
    inc = 0;
    
    if size(traj, 1) > 3
        [A, cntr] = min_enclosing_ellipsoid(traj(:, 2:3)', 1e-2);
        x = cntr(1);
        y = cntr(2);
        if (sum(isinf(A)) + sum(isnan(A))) == 0
            [a, b, inc] = ellipse_parameters(A);
        end
    end

end                    