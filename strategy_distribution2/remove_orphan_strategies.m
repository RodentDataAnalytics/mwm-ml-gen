function [ distr_maps_segs ] = remove_orphan_strategies(distr_maps_segs,weights)
%REMOVE_ORPHAN_STRATEGIES dispose scatter strategies
    
    for i = 1:size(distr_maps_segs,1)
        for j = 1:size(distr_maps_segs,1)
            if distr_maps_segs(i,j) == -1
                break;
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

