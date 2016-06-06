function plot_arena( obj )
%PLOT_ARENA returns the plot of the arena

    CENTRE_X = obj.COMMON_PROPERTIES{4}{1,1};
    CENTRE_Y = obj.COMMON_PROPERTIES{6}{1,1};
    ARENA_RADIUS = obj.COMMON_PROPERTIES{8}{1,1};
    PLATFORM_X = obj.COMMON_PROPERTIES{10}{1,1};
    PLATFORM_Y = obj.COMMON_PROPERTIES{12}{1,1};
    PLATFORM_RADIUS = obj.COMMON_PROPERTIES{14}{1,1};

    axis off;
    daspect([1 1 1]);                      
    rectangle('Position',[CENTRE_X - ARENA_RADIUS, CENTRE_Y - ARENA_RADIUS, ARENA_RADIUS*2, ARENA_RADIUS*2],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
    hold on;
    axis square;
    rectangle('Position',[PLATFORM_X - PLATFORM_RADIUS, PLATFORM_Y - PLATFORM_RADIUS, 2*PLATFORM_RADIUS, 2*PLATFORM_RADIUS],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3); 

end

