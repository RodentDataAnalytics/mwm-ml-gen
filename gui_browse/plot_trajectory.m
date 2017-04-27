function plot_trajectory(trajectory, varargin)
%PLOT_TRAJECTORY plots a trajectory in the plot area

    LineWidth = [];
    Color = [];
    LineStyle = [];
    if ~isempty(varargin)
        for i = 1:2:length(varargin)
            if isequal(varargin{i},'LineWidth')
                LineWidth = varargin{i+1};
            elseif isequal(varargin{i},'Color')
                Color = varargin{i+1};
            elseif isequal(varargin{i},'LineStyle')
                LineStyle = varargin{i+1};
            end
        end
    end
    if isempty(LineWidth)
        LineWidth = 0.5;
    end
    if isempty(Color)
        Color = [0 0 0];
    end
    if isempty(LineStyle)
        LineStyle = '-';
    end
    
    plot(trajectory.points(1,2), trajectory.points(1,3), 'r*', 'LineWidth', 2);
    hold on
    plot(trajectory.points(end,2), trajectory.points(end,3), 'rx', 'LineWidth', 2);
    plot(trajectory.points(:,2), trajectory.points(:,3), '-', 'LineWidth', LineWidth, 'Color', Color, 'LineStyle', LineStyle);
    hold off
end
