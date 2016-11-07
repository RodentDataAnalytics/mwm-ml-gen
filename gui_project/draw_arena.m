function draw_arena(properties, hold_)
%DRAW_ARENA plots the arena.
    
    CENTRE_X = properties{2};
    CENTRE_Y = properties{3};
    ARENA_RADIUS = properties{4};
    PLATFORM_X = properties{5};
    PLATFORM_Y = properties{6};
    PLATFORM_RADIUS = properties{7};
    flipX = properties{8};
    flipY = properties{9};  
    
    % Centralize to point 0,0
    [PLATFORM_X,PLATFORM_Y,CENTRE_X,CENTRE_Y] = centralize_arena(CENTRE_X,CENTRE_Y,PLATFORM_X,PLATFORM_Y,flipX,flipY);
    
    % Plot
    axis off;
    daspect([1 1 1]);                      
    rectangle('Position',[CENTRE_X - ARENA_RADIUS, CENTRE_Y - ARENA_RADIUS, ARENA_RADIUS*2, ARENA_RADIUS*2],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
    hold on;
    axis equal
    axis off
    rectangle('Position',[PLATFORM_X - PLATFORM_RADIUS, PLATFORM_Y - PLATFORM_RADIUS, 2*PLATFORM_RADIUS, 2*PLATFORM_RADIUS],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3); 
    if ~hold_
        hold off;
    end    
    axis equal
    axis off
end

