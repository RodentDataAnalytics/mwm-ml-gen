function [ featval_all ] = compute_features(obj,features,variables)
%% COMPUTE_FEATURES computes the features found in features_list.m.
% The features are computed by calling the appropriate functions required
% per feature and passing the appropriate arguments.
%%
    
    %% progress %%
    if length(obj)<1000
        div = 100;
    else 
        div = 1000;
    end
    
    h = waitbar(0,'Computing features...','Name','Computing Features');
    
    featval_all = zeros(length(obj), length(features));  
    for idx = 1:length(features)
        featval = zeros(length(obj),1);
        fprintf('\nComputing ''%s'' feature values for %d trajectories/segments...', features{idx}{1,2}, length(obj));
        q = floor(length(obj) / div);
        fprintf('0.0% '); 
        
        str = ['Feature ',num2str(idx),'/',num2str(length(features)),': ',sprintf('%s',features{idx}{1,2})];
        waitbar(0,h,str);
         
        for i = 1:length(obj)
            switch length(features{idx})
                case 3 % no COMMON_PROPERTIES and Extra Values 
                    call_func = str2func(features{idx}{1,3});
                    v_length = 0;
                    values = zeros(1,v_length);  
                    featval(i, idx) = call_func(obj(i));

                case 4 % COMMON_PROPERTIES and no Extra Values
                    call_func = str2func(features{idx}{1,3});
                    v_length = length(features{idx}{1,4});
                    values = zeros(1,v_length);
                    count = 1;
                    for v = 1:length(features{idx}{1,4}) % assign values to the variables
                        for j = 1:length(variables)
                            if strcmp(variables{j},features{idx}{1,4}{v});
                                values(v) = variables{j+1}{1};
                                count = count+1;
                                break;
                            end
                        end    
                    end 
                    featval(i, idx) = call_func(obj(i),values);

                case 5 % COMMON_PROPERTIES and Extra Values
                    call_func = str2func(features{idx}{1,3});
                    v_length = length(features{idx}{1,4}) + length(features{idx}{1,5});
                    values = zeros(1,v_length);
                    count = 1;
                    for v = 1:length(features{idx}{1,4}) % assign values to the variables
                        for j = 1:length(variables)
                            if strcmp(variables{j},features{idx}{1,4}{v});
                                values(v) = variables{j+1}{1};
                                count = count+1;
                                break;
                            end
                        end    
                    end
                    % extra arguments
                    for v = 1:length(features{idx}{1,5});
                        values(count) = features{idx}{1,5}{v};
                        count = count+1;
                    end
                    featval(i, idx) = call_func(obj(i),values);

                otherwise % error
                    error('Error computing feature %d',idx);
            end

            % show the progress
            waitbar(i/length(obj));
            if mod(i, q) == 0
                val = 100.*i/length(obj);
                if val < 10.
                    fprintf('\b\b\b\b\b%02.1f%% ', val);
                else
                    fprintf('\b\b\b\b\b%04.1f%%', val);
                end
            end 
        end
        fprintf('\b\b\b\b\bDone.\n');
        featval_all(:, idx) = featval(:, idx);
    end
    delete(h);
end

