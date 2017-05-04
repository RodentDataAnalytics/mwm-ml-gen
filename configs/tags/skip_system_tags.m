function [contents, index] = skip_system_tags(contents)
%SKIP_SYSTEM_TAGS 

    index = 1;
    for i = 2:size(contents,1)
        if isequal(contents{i,end},'-1')
            index = i;
        end
    end
    index = index + 1;    
    contents = contents(index:end,:);
end

