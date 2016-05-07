function setup = setup_validation( user_input )
    if isempty(user_input) % terminate
        setup = -2;
        return
    end    
    if isempty(str2num(user_input{1,1}))
        setup = -1;
    elseif str2num(user_input{1,1}) > 3 || str2num(user_input{1,1}) < 1
        setup = -1;
    else
        setup = str2num(user_input{1,1});
    end  
end

