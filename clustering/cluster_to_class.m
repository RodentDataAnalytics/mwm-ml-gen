function mapping = cluster_to_class( sz_clusters, class_idx, cluster_idx, varargin )
%CLUSTER_TO_CLASS Maps clusters to classes       
    
    [min_samples_p, min_samples_exp, discard_mixed] = process_options(varargin, ...
        'MinSamplesPercentage', 0.01, ...
        'MinSamplesExponent', 0.75, ...
        'DiscardMixed', 1);
    
    classes = sort(unique([class_idx{:}]));
    nclasses = length(classes);    
    nclusters = length(sz_clusters);
    mapping = zeros(1, nclusters);
    
    for j = 1:nclusters
        % count elements of each class
        nmax = 0;
        iclass = 0;
        for k = 1:nclasses
            n = 0;
            % count elements of this class            
            for i = 1:length(cluster_idx)               
                if cluster_idx(i) == j % match cluster
                    if any(classes(k) == class_idx{i})                        
                        n = n + 1;                    
                    else
                        % see if we have other classes here
                        if discard_mixed && any(class_idx{i} > 0)
                            % other classes present, move to next class
                            n = 0;
                            break;
                        end
                    end
                end
            end
            
            if n > nmax
                nmax = n;
                iclass = k;
            end
        end
        
        % see if we have the minimum number of samples (proportional to the
        % cluster size)
        if sz_clusters(j) > 0
            pmin = max(min_samples_p, (1/sz_clusters(j))^min_samples_exp);
        
            if iclass ~= 0 && nmax >= pmin*sz_clusters(j)
                mapping(j) = classes(iclass);
            end
        end
    end    
end
