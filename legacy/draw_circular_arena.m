function draw_circular_arena( config )
    %CIRCULAR_ARENA Summary of this function goes here
    %   Detailed explanation goes here
    ra = config.property('ARENA_R');
    x0 = config.property('CENTRE_X');
    y0 = config.property('CENTRE_Y');

    rectangle('Position',[x0 - ra, y0 - ra, ra*2, ra*2],...
        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
end