function [ pts ] = chop_end_points(PLATFORM_X,PLATFORM_Y,PLATFORM_RADIUS,pts)
%CHOP_END_POINTS chops points at the end on top of the platform   

    npts = size(pts, 1);
    cuti = npts;
    for k = 0:(size(pts, 1) - 1)
        if sqrt((pts(npts - k, 2) - PLATFORM_X)^2 + (pts(npts - k, 3) - PLATFORM_Y)^2) > 1.5*PLATFORM_RADIUS;
            break;
        end
        cuti = npts - k - 1;
    end
    %In case we have very few pts left take the full trajectory
    if cuti < length(pts) - (85*length(pts))/100
        cuti = length(pts);
    end    
    pts = pts(1:cuti, :);
end

