function result = check_tags(ABBREVIATION,DESCRIPTION,data,idx)
%CHECK_TAGS checks if tag's properties are correct:

%ABBREVIATION, DESCRIPTION = unique, non-empty
%WEIGHT = integer, non-empty, larger than zero

    result = 0;
    
    %Abbrevistion (non-empty)
    if isempty(ABBREVIATION)
        errordlg('Abbreviation cannot be empty','Error');
        return;
    end
    %Description (non-empty)
    if isempty(DESCRIPTION)
        errordlg('Abbreviation cannot be empty','Error');
        return;
    end    

    for i = 1:size(data,1)
        if i == idx %only if editing
            continue;
        end
        if isequal(ABBREVIATION,data{i,1})
            errordlg('Abbreviation already exists','Error');
            return
        end
        if isequal(DESCRIPTION,data{i,2})
            errordlg('Name already exists','Error');
            return
        end            
    end
    
    result = 1;
end

