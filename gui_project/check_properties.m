function [error] = check_properties(properties)
%CHECK_PROPERTIES checks if properties contains numeric values

    error_ = zeros(1,length(properties)-2);
    for i = 1:length(properties)-2
        if isempty(properties{i})
            error_(i) = 1;
        end
    end
     
    if error_
        error = 1;
        errordlg('Properties field need to contain numeric values','Input Error');
        return
    else
        if properties{1} <= 0 || properties{4} <= 0 || properties{7} <= 0
            errordlg('Trial timeour, arena and platform radious cannot be less or equal to 0','Input Error');
            error = 1;
            return
        else
            error = 0;
        end   
    end   
end

