function result = check_tags(ABBREVIATION,DESCRIPTION,WEIGHT,data,varargin)
%CHECK_TAGS checks if tag's properties are correct:

%ABBREVIATION, DESCRIPTION = unique, non-empty
%WEIGHT = integer, non-empty


    result = 0;
    %Do not check for dublicates (edit)
    if ~isempty(varargin)
        if isempty(ABBREVIATION)
            errordlg('Abbreviation cannot be empty','Error');
            return;
        elseif isempty(DESCRIPTION)    
            errordlg('Name cannot be empty','Error');
            return;
        elseif isempty(WEIGHT)
            errordlg('Weight cannot be empty','Error');
            return; 
        elseif isempty(str2num(WEIGHT))
            errordlg('Weight needs to have an interger value','Error');
            return;
        else
            result = 1;
            return; 
        end
    end    

    %Do full check
    %Abbrevistion (non-empty, unique)
    if isempty(ABBREVIATION)
        errordlg('Abbreviation cannot be empty','Error');
        return;
    else
        for i = 2:size(data,1)
            if isequal(ABBREVIATION,data{i,1})
                errordlg('Abbreviation already exists','Error');
                return;
            end 
        end     
    end 
    %Description (non-empty, unique)
    if isempty(DESCRIPTION)
        errordlg('Name cannot be empty','Error');
        return;
    else
        for i = 2:size(data,1)
            if isequal(DESCRIPTION,data{i,2})
                errordlg('Name already exists','Error');
                return;
            end 
        end     
    end 
    %Weight (non-empty, numeric)
    if isempty(WEIGHT)
        errordlg('Weight cannot be empty','Error');
        return;
    elseif isempty(str2num(WEIGHT))
        errordlg('Weight needs to have an interger value','Error');
        return;
    end 
    
    result = 1;

end

