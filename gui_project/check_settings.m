function [error] = check_settings(settings)
%CHECK_SETTINGS returns 0 if the user has fill all the settings correcly
%or 1 if not.

    error_ = zeros(1,length(settings));
    if isempty(settings{1}) || settings{1} <= 0
        error_(1) = 1;
    end
    if isempty(settings{2}) || ~isempty(find(settings{2}==0))
        error_(2) = 1;
    end

    if error_ 
        error = 1;
    else
        if length(settings{2}) ~= settings{1}
            error = 1;
        else
            error = 0;
        end
    end   
end

