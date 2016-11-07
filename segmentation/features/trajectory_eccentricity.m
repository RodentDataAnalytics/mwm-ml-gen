function ecc = trajectory_eccentricity( traj )
    [~, ~, a, b] = trajectory_boundaries(traj.points);
    ecc = sqrt(1 - a^2/b^2);
end