function distr_strategies_results(segmentation_configs, classification_configs)
%DISTR_STRATEGIES_RESULTS produces the Mean and Maximum Length of 
%consecutive segments of each class with constant weights and after
%adopting differentiated weights for minor and major classes.

    for iter = 1:2
        if iter == 1
            [strat_distr, ~, ~, class_w] = distr_strategies(segmentation_configs, classification_configs, 'weights', 'ones');
        else
            [strat_distr, ~, ~, class_w] = distr_strategies(segmentation_configs, classification_configs, 'weights', 'computed');
        end

        vals = cell(1,length(class_w));
        % do now the other classifications
        for i = 1:size(strat_distr, 1)
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
                            vals{c} = [vals{c}, j - ci - 1];                            
                        end
                        break;
                    elseif cc > 0 && c > 0
                        % real change
                        if j - ci > 1                                                    
                            vals{c} = [vals{c}, j - ci - 1];
                        end
                        c = cc;
                        ci = j;
                    end
                end
            end
        end

        param = g_config.TAGS_CONFIG{2};

        fac = param{5}*(1 - param{6}); % length * ( 1 - overlap% )
        % show results
        for i = 1:g_segments_base_classification.nclasses
            fprintf('\n%s: %.2f (max: %d) == WEIGHT: %.2f', g_segments_base_classification.classes(i).description, fac*mean(vals{i}), fac*max(vals{i}), w(i));
        end   
    end
end

