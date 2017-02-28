function [repl_distr_maps_segs,true_length_maps] = classified_trajectory_arrangement(distr_maps_segs,length_map,my_segments,traj_lengths)
%CLASSIFIED_TRAJECTORY_ARRANGEMENT

    true_length_maps = zeros(size(distr_maps_segs,1),size(distr_maps_segs,2));
    true_length_maps_ = true_length_maps;
    
    for i = 1:size(distr_maps_segs,1)
        iter = find(distr_maps_segs(i,:)~=-1);
        for j = 1:length(iter)-1
            true_length_maps(i,j) = my_segments{i,j+1}.offset - my_segments{i,j}.offset;
        end
        % last
        true_length_maps(i,length(iter)) = traj_lengths(i) - sum(true_length_maps(i,:));
    end    
    
    % reverse
    for i = 1:size(distr_maps_segs,1)
        iter = find(distr_maps_segs(i,:)~=-1);
        for j = length(iter):-1:2
            true_length_maps_(i,j) = (my_segments{i,j}.offset + length_map(i,j)) - (my_segments{i,j-1}.offset + length_map(i,j-1));
        end
        % last
        true_length_maps_(i,1) = traj_lengths(i) - sum(true_length_maps_(i,:));
    end   
    
    % calculate the final lengths
    repl_distr_maps_segs = distr_maps_segs;
    for i = 1:size(distr_maps_segs,1)
        iter = find(distr_maps_segs(i,:)~=-1);
        for j = length(iter)-1:-1:1
            if (my_segments{i,j}.offset + length_map) < my_segments{i,length(iter)}.offset
                idx = j;
                break;
            end
        end
        % idx shows the first segment that does not overlap the final
        idx = idx + 1;
        % now idx shows the first segment that overlaps the final but with a
        % small percentage
        idx = idx + 1;
        % split this point into 2
        k = 1;
        for j = idx:length(iter)
            true_length_maps(i,length(iter) + k +1) = true_length_maps_(i,j);
            repl_distr_maps_segs(i,length(iter) + k +1) = distr_maps_segs(i,j);
            k = k + 1;
        end
        % this means that the length of this point will be split evenly
        true_length_maps(i,length(iter)) = 0;
        split = (traj_lengths(i) - sum(true_length_maps(i,:))) / 2;
        true_length_maps(i,length(iter)) = split;
        true_length_maps(i,length(iter)+1) = split;
        % and mark this segment for spliting
        repl_distr_maps_segs(i,length(iter)) = distr_maps_segs(i,length(iter));
        repl_distr_maps_segs(i,length(iter)+1) = distr_maps_segs(i,length(iter)-1);
    end
    % make sure that 'repl_distr_maps_segs' has no zeros
    for i = 1:size(repl_distr_maps_segs,1)
        idx = find(repl_distr_maps_segs(i,:) == -1);
        if isempty(idx)
            continue;
        end
        for j = idx(end):size(repl_distr_maps_segs,2)
            repl_distr_maps_segs(i,j) = -1;
        end
    end
end

