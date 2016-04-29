function [ entropy ] = clustering_entropy(k, idxs, n, labels )
%CLUSTERING_ENTROPY Evaluates clustering quality by its entropy        
    % compute cluster sizes    
    idx_single = cellfun( @(x) length(x) == 1, labels);  
    szs = zeros(1, k);
    for i = 1:k
        szs(i) = length(find(idxs == i));
    end    
    entropies = zeros(1, k);   
    for i = 1:k        
        if szs(i) > 0
            for j = 1:n                
                nlabels = length(labels(idx_single & idxs == i) == j);
                if nlabels > 0
                    entropies(i) = entropies(i) - 1/log(k)*( nlabels/szs(i)*log(nlabels / szs(i)) );
                end
            end
        end
    end    
    % return averaged entropy
    entropy = sum(szs.*entropies) / sum(szs);
end