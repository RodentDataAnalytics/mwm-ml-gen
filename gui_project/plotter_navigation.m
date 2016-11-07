function plotter_navigation(hObject,handles,eventdata)
%PLOTTER_NAVIGATION

    %get the data
    raw_data = get(handles.table,'UserData');
    raw_data = raw_data{2};
    %get the table's data
    data = get(handles.table,'Data');
    %get the pointer
    idx = str2num(get(handles.navigator,'String'));
    %if no pointer -> return
    if isempty(idx)
    	return
    end    
    %recognize the hObject
    tag = get(hObject,'Tag');
    switch tag
        case 'ok'
            if idx > size(data,1) || idx <= 0
                return
            end
            %same index
            new_index = idx;
        case 'previous'    
            if idx-1 > size(data,1) || idx-1 <= 0
                return
            end
            %index -1
            new_index = idx-1;
        case 'next'    
            if idx+1 > size(data,1) || idx+1 <= 0
                return
            end
            %index +1
            new_index = idx+1;
    end   
    
    %update the GUI
    set(handles.navigator,'String',num2str(new_index));
    %if availability = 0 plot a circle and return
    if data{new_index,7} == 0
        cla
        default_plot('circle');
        return
    end    
    %plot
    ses = data{new_index,2};
    name = data{new_index,1};
    for i = 1:size(raw_data,1)
        if isequal(raw_data{i,ses}{1},name)
            points = raw_data{i,ses}{4};
            check_and_draw_arena(eventdata,handles)
            check_and_draw_trajectory(eventdata,handles,points);
            return;
        end
    end  
end

