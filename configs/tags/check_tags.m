function result = check_tags(ABBREVIATION,DESCRIPTION,WEIGHT,data,varargin)
%CHECK_TAGS checks if tag's properties are correct:

%ABBREVIATION, DESCRIPTION = unique, non-empty
%WEIGHT = integer, non-empty, larger than zero

    result = 0;
    
    %Abbrevistion (non-empty, unique)
    if isempty(ABBREVIATION)
        errordlg('Abbreviation cannot be empty','Error');
        return;
    else    
        if ~isempty(varargin{1})
            data{varargin{1},1} = ABBREVIATION;
        else
            data{end+1,1} = ABBREVIATION;
        end
        c = unique(data(:,1));
        if size(c,1) ~= size(data,1)
            errordlg('Abbreviation already exists','Error');
            return;     
        end
    end 
    %Description (non-empty, unique)
    if isempty(DESCRIPTION)
        errordlg('Name cannot be empty','Error');
        return;
    else
        if ~isempty(varargin{1})
            data{varargin{1},2} = DESCRIPTION;
        else
            data{end,2} = DESCRIPTION;
        end
        c = unique(data(:,2));
        if size(c,1) ~= size(data,1)
            errordlg('Name already exists','Error');
            return;     
        end
    end 
    %Weight (non-empty, numeric, larger than zero)
    if isempty(WEIGHT)
        errordlg('Weight cannot be empty','Error');
        return;
    elseif isempty(str2double(WEIGHT)) || isnan(str2double(WEIGHT)) || str2double(WEIGHT) <= 0
        errordlg('Weight needs to have an interger value larger than 0','Error');
        return;
    end
    
    result = 1;
end

