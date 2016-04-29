function [ m ] = confusion_matrix( labels, assigned, ntags )
%CONFUSION_MATRIX
    % take into account only labels that do not have multiple values
    idx_single = cellfun( @(x) length(x) == 1, labels);    
    m = zeros(ntags, ntags);
    for i = 1:ntags
        for j = 1:ntags
            m(i, j) = sum(cell2mat(labels(idx_single)) == i & assigned(idx_single) == j);
        end
    end
end