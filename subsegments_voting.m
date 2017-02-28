function [ repl_distr_maps_segs ] = subsegments_voting(repl_distr_maps_segs,true_length_maps,my_segments,distr_maps_segs,length_map,w)
%SUBSEGMENTS_VOTING 
    
    class_vector = zeros(1,length(w));
    
    for i = 1:size(true_length_maps,1)
        coverage = 0;
        p = length(find(true_length_maps(i,:) ~= 0));
        for j = 1:p
            coverage = coverage + true_length_maps(i,j);
            Start = 1;
            %End = 1;
            p1 = length(find(length_map(i,:) ~= 0));
            for k = 1:p1
                if ~isequal(my_segments{i,k},-1)
                    my_cov = my_segments{i,k}.offset + length_map(i,k);
                    if coverage > my_segments{i,k}.offset && coverage < my_cov
                        End = k;
                    elseif coverage > my_cov
                        Start = k+1;
                    else
                        break;
                    end 
                else
                    % now we are in the last segment
                    % find all the segments that overlaps the last one
                    index = length(find(distr_maps_segs(i,:) ~= -1));
                    last_segment_offset = my_segments{i,index}.offset;
                    for z = index-1:-1:1
                        if my_segments{i,z}.offset + length_map(i,z) < last_segment_offset
                            pointer = z+1;
                            break;
                        end
                    end
                    End = index;
                    Start = pointer;
                    break;
                end
            end
            for c = 1:length(class_vector)
                counter = length(find(distr_maps_segs(i,Start:End) == c));
                class_vector(c) = counter;
            end
            [val,pos] = max(class_vector.*w);
            if val > 0
                repl_distr_maps_segs(i,j) = pos;
            else
                repl_distr_maps_segs(i,j) = 0;
            end
        end
    end
    
end

