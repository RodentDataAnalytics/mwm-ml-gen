function draw_arena(CENTRE_X,CENTRE_Y,ARENA_RADIUS,PLATFORM_X,PLATFORM_Y,PLATFORM_RADIUS,flipX,flipY)
%DRAW_ARENA creates a figure of the arena

    % Fix platform position
    PLATFORM_X = PLATFORM_X - CENTRE_X;
    PLATFORM_Y = PLATFORM_Y - CENTRE_Y; 
    CENTRE_X = 0;
    CENTRE_Y = 0;
    % Flip platform position if needed
    if flipX
        PLATFORM_X = -PLATFORM_X;
    end
    if flipY
        PLATFORM_Y = -PLATFORM_Y;
    end    
    figure
    axis off;
    daspect([1 1 1]);                      
    rectangle('Position',[CENTRE_X - ARENA_RADIUS, CENTRE_Y - ARENA_RADIUS, ARENA_RADIUS*2, ARENA_RADIUS*2],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
    hold on;
    axis square;
    rectangle('Position',[PLATFORM_X - PLATFORM_RADIUS, PLATFORM_Y - PLATFORM_RADIUS, 2*PLATFORM_RADIUS, 2*PLATFORM_RADIUS],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3); 

end

