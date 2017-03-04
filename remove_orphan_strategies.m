function [ distr_maps_segs ] = remove_orphan_strategies(distr_maps_segs,true_length_maps,weights)
%REMOVE_ORPHAN_STRATEGIES dispose scatter strategies

    % Positive numbers represent strategies, 
    % -1 marks the end of the trajectory,
    % any other negative number or 0 reprent unknown
    % The below loops make all numbers < -1 equal to 0
    t = find(distr_maps_segs < -1);
    if ~isempty(t)
        m = min(distr_maps_segs);
        for k = m:-1
            for i = 1:size(distr_maps_segs,1)
                for j = 1:size(distr_maps_segs,2)
                    if  distr_maps_segs(i,j) == k;
                        distr_maps_segs(i,j) = 0;
                    end
                end
            end
        end
    end
    
    strats = sort(unique(distr_maps_segs));
    traj_strats_map = zeros(length(strats)-1,size(distr_maps_segs,2));
    
    for i = 1:size(distr_maps_segs,1)
        % For each row save in a matrix the indexes of each strategy and in
        % the last row of this matrix save the indexes of the undefined
        for j = 1:size(traj_strats_map,1) - 2
            idx = find(distr_maps_segs(i,:) == j);
            for k = 1:length(idx)
                traj_strats_map(j,k) = idx(k);
            end
        end
        idx = find(distr_maps_segs(i,:) == 0);
        for k = 1:length(idx)
            traj_strats_map(end,k) = idx(k);
        end           
        
        
        
        
        
        
        
        
        
        
        
        
        
        for j = 1:size(distr_maps_segs,2)
            % end or row
            if distr_maps_segs(i,j) == -1
                break;
            end
            % last
            if j == size(distr_maps_segs,2)
                if distr_maps_segs(i,j-1) ~= distr_maps_segs(i,j)
                    distr_maps_segs(i,j) = distr_maps_segs(i,j-1);
                end
                break;
            end
            % first
            if j == 1
                if distr_maps_segs(i,j+1) ~= distr_maps_segs(i,j)
                    distr_maps_segs(i,j) = distr_maps_segs(i,j+1);
                end
                continue;
            end            
            
            
         
                

                
            
            else
                try %if it is the very first one in each row
                    prev = distr_maps_segs(i,j-1);
                catch
                    next = distr_maps_segs(i,j+1);
                    if next > 0
                        distr_maps_segs(i,j) = next;
                    end
                    continue;
                end
                try %the one that has length(distr_maps_segs)
                    next = distr_maps_segs(i,j+1); 
                catch
                    prev = distr_maps_segs(i,j-1);
                    distr_maps_segs(i,j) = prev;
                    break;
                end
                if distr_maps_segs(i,j) ~= prev && distr_maps_segs(i,j) ~= next
                    if prev <= 0
                        distr_maps_segs(i,j) = next;
                    elseif next <= 0
                        distr_maps_segs(i,j) = prev;
                    else
                        if weights(prev) == weights(next)
%                             if HARD_BOUNDS
%                                 distr_maps_segs(i,j) = -3;
%                             else
%                                 distr_maps_segs(i,j) = next;
%                             end
                        else
                            if weights(prev) > weights(next)
                                distr_maps_segs(i,j) = next;
                            else
                                distr_maps_segs(i,j) = prev;
                            end
                        end                            
                    end                        
                end
            end
        end
    end
end