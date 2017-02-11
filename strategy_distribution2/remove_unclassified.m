function [ distr_maps_segs ] = remove_unclassified(segmentation_configs,length_map,distr_maps_segs,w)
%REMOVE_UNCLASSIFIED removes undefined segments

    seg_length = segmentation_configs.SEGMENTATION_PROPERTIES(1);
    seg_overlap = segmentation_configs.SEGMENTATION_PROPERTIES(2);
    min_path_interval = seg_length * (1 - seg_overlap); %minimum path interval
    threshold = seg_length - min_path_interval;

    for i = 1:size(distr_maps_segs,1)
        zeros = find(distr_maps_segs(i,:)==0);
        count = 1;
        for j = 1:size(distr_maps_segs,2)
            if distr_maps_segs(i,j) == -1
                break;
            end
            if distr_maps_segs(i,j) == 0
                k = j;
                counter = 0;
                while distr_maps_segs(i,k) == 0
                    counter = counter + 1;
                    k = k + 1;
                end
                r = rem(counter,2);
                if r
                    for z = 1:floor(counter / 2)
                        distr_maps_segs(i,j) = distr_maps_segs(i,j-1);
                        distr_maps_segs(i,j+counter-z) = distr_maps_segs(i,j+counter);
                    end
                    if j == 1
                        distr_maps_segs(i, j) = distr_maps_segs(i, j + counter);
                        continue;
                    end
                    prev = distr_maps_segs(i, j - 1);
                    try
                        next = distr_maps_segs(i, j + counter);
                    catch
                        distr_maps_segs(i, j) = prev;
                        continue;
                    end
                    if w(prev) > w(next)
                        distr_maps_segs(i, j + floor(counter/2) + 1) = prev;
                    else
                        distr_maps_segs(i, j + floor(counter/2) + 1) = next;
                    end
                else
                    for z = 1:counter / 2
                        distr_maps_segs(i,j) = distr_maps_segs(i,j-1);
                        distr_maps_segs(i,j+counter-z) = distr_maps_segs(i,j+counter);
                    end
                end
            end
        end   
    end
end

