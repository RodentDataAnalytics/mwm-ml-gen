function [similarity,strat] = check_similarity(segmentations,classifications)

    similarity = [];
    strat = [];
    
    %find matched segments
    [output,~] = match_segments(segmentations);
    if isempty(output)
        return
    end
    %get the two class maps
    class_map1 = classifications{1}.CLASSIFICATION.class_map;
    class_map2 = classifications{2}.CLASSIFICATION.class_map;
    %first will be the one with the most segments
    if length(class_map1) < length(class_map2)
        tmp = class_map1;
        class_map1 = class_map2;
        class_map2 = tmp;
    end
    %find the segments that don't have similar classes
    not_similar = 0;
    a = class_map1(output(:,1));
    b = class_map2(output(:,2));
    for i = 1:length(a)
        if a(i) ~= b(i)
            not_similar = not_similar + 1;
        end
    end
    %compute percentage of similarity; only for the matched segments
    similarity = (not_similar * 100) / size(output,1);
    similarity = 100-similarity;
    %find the amount of strategies per group; only for the matched segments
    unique_ab = [unique(class_map1),unique(class_map2)];
    unique_ab = unique(unique_ab);
    strat = zeros(2,length(unique_ab));
    strat = [unique_ab;strat];
    for i = 1:length(unique_ab)
        first = find(a == unique_ab(i));
        second = find(b == unique_ab(i));
        strat(2,i) = length(first);
        strat(3,i) = length(second);
    end      
end