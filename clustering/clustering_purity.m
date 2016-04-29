function [ purity ] = clustering_purity( k, idxs, labels )
%CLUSTERING_PURITY computes cluster sizes and returns the averaged entropy

    % compute cluster sizes
    szs = zeros(1, k);
    for i = 1:k
        szs(i) = length(find(idxs == i));
    end    
    purities = zeros(1, k);
    for i = 1:k
        elem = find(idxs == i);    
        intersections = zeros(1, k);
        for j = 1:k
            label_elem = find(labels == j);
            intersections(j) = length(intersect(label_elem, elem));            
        end        
        if szs(i) ~= 0
            purities(i) = max(intersections) / szs(i);        
        else
            purities(i) = 0;
        end
    end    
    % return averaged entropy
    purity = sum(szs.*purities) / sum(szs);
end
