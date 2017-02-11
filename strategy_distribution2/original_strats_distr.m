function [distr_maps_segs] = original_strats_distr(distr_maps_segs,segments,w,length_map)
%ORIGINAL_STRATS_DISTR performs the original strategies distribution
      
    %seg_length = segmentation_configs.SEGMENTATION_PROPERTIES(1);
    %seg_overlap = segmentation_configs.SEGMENTATION_PROPERTIES(2);
    %min_path_interval = seg_length * (1 - seg_overlap); %minimum path interval
    sigma = 4;
    pointer = 1; %specifies the end of the trajectory
    % for each trajectory
    for i = 1:size(distr_maps_segs,1)
        % take all the segments of the trajectory
        traj_segments = find(distr_maps_segs(i,:) ~= -1);
        traj_segments = segments(pointer:traj_segments(end)+pointer-1);
        pointer = pointer + length(traj_segments);
        % for the segments of the trajectory
        for j = 1:size(distr_maps_segs,2)
            class_distr_traj = -1.*ones(1,length(w)); %score of each strategy
            if isequal(distr_maps_segs(i,j),-1)
                break;
            end
            wi = j; %current segment
            wf = j; %overlapped segments
            coverage = traj_segments(j).offset + length_map(i,j);
            for k = j+1:size(length(traj_segments))
                if traj_segments(k).offset > coverage
                    wf = j + 1;
                    break;
                end
            end
            m = (wi + wf) / 2; %mid-point
            for k = wi:wf
                if distr_maps_segs(i,k) > 0
                    col = distr_maps_segs(i,k);
                    %equation 2, supplementary material page 7
                    val = w(col)*exp(-(k-m)^2 / (2*sigma^2));
                    if class_distr_traj(col) == -1
                        class_distr_traj(col) = val;
                    else
                        class_distr_traj(col) = class_distr_traj(col) + val;
                    end
                %elseif DISCARD_UNDEFINED
                %    undefined(j) = undefined(j) + 1;
                %end
                end
            end
            [val,pos] = max(class_distr_traj);
            if val > 0
                distr_maps_segs(i,j) = pos;
            else
                distr_maps_segs(i,j) = 0;
            end
        end 
    end    
end

