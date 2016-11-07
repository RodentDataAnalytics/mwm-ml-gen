function [contents] = gui_configs_get_data(handles)
%GUI_CONFIGS_GET_DATA collects all the selected info and assign them to
%contents

    contents = read_configs;
    
    idx1 = get(handles.fname,'Value');
    idx2 = get(handles.fsize,'Value');
    idx3 = get(handles.lwidth,'Value');
    idx4 = get(handles.export,'Value');
    idx5 = get(handles.export_style,'Value');
    a = get(handles.fname,'String');
    b = get(handles.fsize,'String');
    c = get(handles.lwidth,'String');
    d = get(handles.export,'String');
    e = get(handles.export_style,'String');
    
    for i = 1:size(contents,1)
        if isequal(contents{i,1},'FontName')
            contents{i,2} = a{idx1,1};
        elseif isequal(contents{i,1},'FontSize')
            contents{i,2} = b{idx2,1};
        elseif isequal(contents{i,1},'LineWidth')
            contents{i,2} = c{idx3,1};
        elseif isequal(contents{i,1},'Export')
            split = strfind(d{idx4,1},'.');
            split = d{idx4,1}(split:end-1);
            contents{i,2} = split;
        elseif isequal(contents{i,1},'ExportStyle')
            contents{i,2} = e{idx5,1};
        end
    end 
end

