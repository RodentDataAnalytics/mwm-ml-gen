function [w] = weights_legacy(classification_configs,strat_distr)
%COMPUTED_WEIGHTS computes adopted weights for minor and major classes

    max_len = zeros(1,length(classification_configs.CLASSIFICATION_TAGS));
    all_max_len = zeros(size(strat_distr,1),length(max_len));

    for i = 1:size(strat_distr, 1)
        % Skip the DF
        if strat_distr(i,1) == -2
            continue;
        end
        c = strat_distr(i, 1);
        ci = 1;
        for j = 2:size(strat_distr, 2)
            cc = strat_distr(i, j);
            if cc ~= c                
                if c <= 0
                    c = cc;
                    ci = j;
                elseif cc == -1
                    % last probably
                    if j - ci > 1   
                        max_len(c) = max(max_len(c), j - ci - 1);  
                        all_max_len(i,c) = max(all_max_len(i,c), j - ci - 1);
                    end
                    break;
                elseif cc > 0 && c > 0
                    % real change
                    if j - ci > 1                                
                        max_len(c) = max(max_len(c), j - ci - 1); 
                        all_max_len(i,c) = max(all_max_len(i,c), j - ci - 1);
                    end
                    c = cc;
                    ci = j;
                end
            end
        end
    end
    
    avg_w = zeros(1,length(max_len));
    for i = 1:length(max_len)
        a = length(find(all_max_len(:,i) > 0));
        avg_w(i) = sum(all_max_len(:,i))./a;
    end
    max_avg_w = max(avg_w);
    w = repmat(max_avg_w, 1, length(avg_w)) ./ avg_w;
end