function [PLATFORM_X,PLATFORM_Y,CENTRE_X,CENTRE_Y] = centralize_arena(CENTRE_X,CENTRE_Y,PLATFORM_X,PLATFORM_Y,flipX,flipY)
%CENTRALIZE_ARENA moves the arena center to point 0,0

    % Fix platform position (centralize to point 0,0)
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
end

