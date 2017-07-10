function browse_update_counting(handles)
%BROWSE_UPDATE_COUNTING recounts the labels

    mode = get(handles.plotter,'UserData');
    if mode == 1
        labels = get(handles.tag_box,'UserData');
        if isempty(labels)
            return;
        end
    elseif mode == 3
        labels = get(handles.listbox,'UserData');
        if isempty(labels)
            return;
        end        
    else
        return;
    end
    
    tags = get(handles.available_tags,'String');
    table = zeros(length(tags)+1,1);
    labels = labels{2};%(index,:)
    for i = 1:size(labels,1);
        if ~isempty(labels{i,2})
            table(1) = table(1) + 1;
        else
            for j = 1:length(tags)
                if isequal(labels{i,1},tags{j})
                    table(j) = table(j) + 1;
                    break;
                end
            end
        end
    end 
    total = sum(table(1:end-1));
    table(end) = total;
    set(handles.counting,'Data',table);
end