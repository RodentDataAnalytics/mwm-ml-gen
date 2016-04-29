function new_list = property_list_set_default( list, name, val )
    found = 0;
    new_list = list;
    for i = 1:2:length(list)
        if strcmp(list{i}, name)
            found = 1;
            break;
        end
    end
    if ~found
        if isempty(new_list)
            new_list = {name, val};
        else
            new_list = [new_list, name, val];
        end
    end
end