function check_and_draw_arena(eventdata,handles)
%CHECK_AND_DRAW_ARENA checks if properties are correct and plots the arena
    
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
    if isequal(str,'Arena')
        cla
        draw_arena(properties,0);
    elseif isequal(str,'Both')
        cla
        draw_arena(properties,1);
    else % <= , => , ok
        cla
        draw_arena(properties,1);
    end  
end

