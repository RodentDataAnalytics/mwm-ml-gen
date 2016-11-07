function draw_trajectory(pts,hold_)
%DRAW_TRAJECTORY plots a trajectory

    plot(pts(1,2), pts(1,3), 'r*', 'LineWidth', 2);
    hold on
    axis equal
    axis off
    plot(pts(end,2), pts(end,3), 'ro', 'LineWidth', 2);
    plot(pts(:,2), pts(:,3), '-', 'LineWidth', 0.5, 'Color', [0 0 0]);
    if ~hold_
        hold off
    end   
    axis equal
    axis off
end

