function [temp, idx] = hide_gui(gui_name)
%HIDE_GUI hides currect GUI

    temp = findobj('Type','figure');
    for i = 1:length(temp)
        name = get(temp(i),'Name');
        if isequal(name,gui_name)
            set(temp(i),'Visible','off'); 
            idx = i;
            break;
        end
    end    

end

