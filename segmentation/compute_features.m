function [ featval_all ] = compute_features(obj,features,variables,varargin)
%% COMPUTE_FEATURES computes the features found in features_list.m.
% The features are computed by calling the appropriate functions required
% per feature and passing the appropriate arguments.
%%

    WAITBAR = 1;
    DISPLAY = 1;
    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        elseif isequal(varargin{i},'DISPLAY')
            DISPLAY = varargin{i+1};
        end
    end
    
    %% progress %%
    if DISPLAY
        if length(obj)<1000
            div = 100;
        else 
            div = 1000;
        end
    end
    
    if WAITBAR
        h = waitbar(0,'Computing features...','Name','Computing Features');
    end
    
    featval_all = zeros(length(obj), length(features));  
    for idx = 1:length(features)
        featval = zeros(length(obj),1);
        if DISPLAY
            fprintf('\nComputing ''%s'' feature values for %d trajectories/segments...', features{idx}{1,2}, length(obj));
            q = floor(length(obj) / div);
            fprintf('0.0% '); 
        end
        if WAITBAR
            str = ['Feature ',num2str(idx),'/',num2str(length(features)),': ',sprintf('%s',features{idx}{1,2})];
            waitbar(0,h,str);
        end
         
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
            
            % NaN values = 0
            if isnan(featval(i, idx))
                featval(i, idx) = 0;
            end    

            % show the progress
            if WAITBAR
                waitbar(i/length(obj));
            end
            if DISPLAY
                if mod(i, q) == 0
                    val = 100.*i/length(obj);
                    if val < 10.
                        fprintf('\b\b\b\b\b%02.1f%% ', val);
                    else
                        fprintf('\b\b\b\b\b%04.1f%%', val);
                    end
                end 
            end
        end
        if DISPLAY
            fprintf('\b\b\b\b\bDone.\n');
        end
        featval_all(:, idx) = featval(:, idx);
    end
    if WAITBAR
        delete(h);
    end
end

