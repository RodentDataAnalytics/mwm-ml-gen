function check_and_draw_trajectory(eventdata,handles,pts)
%CHECK_AND_DRAW_TRAJECTORY checks if properties are correct and plots the
%trajectory

    % Get the properties
    properties = get_properties( handles );
                         
    % Check if they are correct
    [error] = check_properties(properties);    
    if error
        return;
    end      
    
    % Get the button pressed
    str = eventdata.Source.String;

    % Perform action
    if isequal(str,'Trajectory')
        cla;
        %centralize the trajectory to point 0,0
        pts = centralize_trajectory(properties,pts);
        draw_trajectory(pts,0);
    elseif isequal(str,'Both')
        %centralize the trajectory to point 0,0 and chop end points
        pts = centralize_trajectory(properties,pts,'chop');
        draw_trajectory(pts,1);
    else % <= , => , ok
        pts = centralize_trajectory(properties,pts,'chop');
        draw_trajectory(pts,1);
    end  
end

