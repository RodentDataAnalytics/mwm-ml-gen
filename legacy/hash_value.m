function hash = hash_value( val )
%HASH_VALUE Summary of this function goes here
%   Detailed explanation goes here    
    if length(val) == 0
        hash = 0;
    elseif length(val) > 1
        if iscell(val)
            hash = hash_value(val{1});
            for i = 2:length(val)
                hash = hash_combine(hash, hash_value(val{i}));
            end
        else
            hash = hash_value(val(1));
            for i = 2:length(val)
                hash = hash_combine(hash, hash_value(val(i)));
            end
        end
    else
        if iscell(val)
            hash = hash_value(val{1});
        else
            if isa(val, 'function_handle')
                hash = hash_value(func2str(val));
            else
                hash = uint32(mod(val, 2^32));
            end
        end
    end
end