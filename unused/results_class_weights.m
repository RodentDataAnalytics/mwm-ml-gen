% Produces the Mean and Maximum Length of consecutive segments of each
% class for the x cm / y% overlap classification (x,y specified by the 
% user) with constant weights and after adopting differentiated weights
% for minor and major classes.

function results_class_weights(segmentation_configs,classification_configs)
    
    % load all trajectories
    base_classification = classification_configs.CLASSIFICATION;
    seg_properties = segmentation_configs.SEGMENTATION_PROPERTIES;

    for iter = 1:2
        fprintf('\n*****************');
        % 1: results giving all classes the same weight
        w = ones(1, base_classification.nclasses);
        if iter == 1
            strat_distr = base_classification.mapping_ordered(segmentation_configs,classification_configs,'DiscardUnknown', 1, 'MinSegments', 1, 'ClassesWeights', w);
        else
            [strat_distr, ~, ~, w] = base_classification.mapping_ordered(segmentation_configs,classification_configs,'DiscardUnknown', 1, 'MinSegments', 1);
            w = base_classification.classes_weights(segmentation_configs,classification_configs);
        end
        
        vals = arrayfun( @(x) [], 1:base_classification.nclasses, 'UniformOutput', 0);
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
        fac = seg_properties(1)*(1 - seg_properties(2)); % length * ( 1 - overlap% )
        % show results
        for i = 1:base_classification.nclasses
            fprintf('\n%s: %.2f (max: %d) == WEIGHT: %.2f', base_classification.classes{1,i}{1,2}, fac*mean(vals{i}), fac*max(vals{i}), w(i));
        end
    end
end
