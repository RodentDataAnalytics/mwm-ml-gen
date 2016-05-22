classdef clone_struct
    %CLONE_STRUCT clones a struct.
    
    properties(GetAccess = 'public', SetAccess = 'private')  
        ORIGINAL_OBJ = [];
    end
    
    properties(GetAccess = 'public', SetAccess = 'public') 
        CLONED_OBJ = [];
    end
    
    methods
        function inst = clone_struct(obj)
            inst.ORIGINAL_OBJ = obj;
            inst.CLONED_OBJ = obj;
        end    
    end
    
end

