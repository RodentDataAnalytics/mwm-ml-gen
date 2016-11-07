function [error] = check_format(format)
%CHECK_FORMAT returns 0 if the user has fill all the format cells
%or 1 if not.

    error_ = zeros(1,length(format)-1);
    for i = 2:length(format)
        if isempty(format{i})
            error_(i-1) = 1;
        end
    end
    
    if error_
        error = 1;
    else
        error = 0;
    end    
end

