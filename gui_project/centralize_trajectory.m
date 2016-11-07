function [pts] = centralize_trajectory(properties,pts,varargin)
%CENTRALIZE_TRAJECTORY moves the trajectory center to point 0,0

    CENTRE_X = properties{2};
    CENTRE_Y = properties{3};
    flipX = properties{8};
    flipY = properties{9};  
    
    % Move centre to 0,0
    pts(:,2) = pts(:,2) - CENTRE_X;
    pts(:,3) = pts(:,3) - CENTRE_Y;  
    
    % Flip if needed
    if flipX
        pts(:,2) = -pts(:,2);
    end    
    if flipY
        pts(:,3) = -pts(:,3);
    end              
    
    % Chop points at the end on top of the platform   
    if ~isempty(varargin)
        PLATFORM_X = properties{5};
        PLATFORM_Y = properties{6};
        PLATFORM_RADIUS = properties{7};    
        %first take the new platform location
        [PLATFORM_X,PLATFORM_Y,~,~] = centralize_arena(CENTRE_X,CENTRE_Y,PLATFORM_X,PLATFORM_Y,flipX,flipY);
        pts = chop_end_points(PLATFORM_X,PLATFORM_Y,PLATFORM_RADIUS,pts);
    end
end

