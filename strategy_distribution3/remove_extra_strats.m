function [ distr_maps_segs ] = remove_extra_strats( distr_maps_segs )
%REMOVE_EXTRA_STRATS removes marked segments (e.g. -3)
    for i = 1:size(distr_maps_segs,1)
        for j = 1:size(distr_maps_segs,2)
            if distr_maps_segs(i,j) == -3
                %distr_maps_segs(i,j) = distr_maps_segs(i,j-1);
                % or
                distr_maps_segs(i,j) = distr_maps_segs(i,j+1);
            end
        end
    end
end

