function plot_h = plot_trajectory( trajectory )
%PLOT_TRAJECTORY plots a trajectory in the plot area

plot(trajectory.points(1,2), trajectory.points(1,3), 'r*', 'LineWidth', 2);
hold on
plot(trajectory.points(end,2), trajectory.points(end,3), 'ro', 'LineWidth', 2);
plot(trajectory.points(:,2), trajectory.points(:,3), '-', 'LineWidth', 0.5, 'Color', [0 0 0]);
hold off

end

