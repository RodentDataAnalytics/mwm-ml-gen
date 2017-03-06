function [ distr_maps_segs ] = remove_unclassified(segmentation_configs,distr_maps_segs,length_map,varargin)
%REMOVE_UNCLASSIFIED removes undefined segments only if their length does
%not exceed a certain threshold

    for i = 1:length(varargin)
        if isequal(varargin{i},'THRESHOLD')
            threshold = varargin{i+1};
        end
    end   
    
    if ~exist('threshold','var')
        seg_length = segmentation_configs.SEGMENTATION_PROPERTIES(1);
        seg_overlap = segmentation_configs.SEGMENTATION_PROPERTIES(2);
        min_path_interval = seg_length * (1 - seg_overlap); %minimum path interval
        threshold = seg_length + min_path_interval;
    end
    
    for i = 1:size(distr_maps_segs,1)
        % find indexes that have undefined segments
        Zeros = find(distr_maps_segs(i,:)==0);
        k = 1;
        while k <= length(Zeros)
            counter = 1; % counter successive indexes
            try
                while Zeros(k) == Zeros(k + counter) - counter
                    counter = counter + 1;
                end
            catch
            end
            chunk = Zeros(k:k+counter-1); % contains the successive indexes
            len = 0;
            %for j = k:counter + k - 1
            for j = 1:length(chunk)
                len = len + length_map(i,chunk(j)); % length of successive undefined segments
            end
            if len < threshold % purge undefined only if their length is smaller than the threshold
                idx = find(distr_maps_segs(i,:)~=0 & distr_maps_segs(i,:)~=-1);
                if isempty(idx)
                    continue;
                end
                if chunk(1) < idx(1) % if it is the first element(s)
                    distr_maps_segs(i,chunk(1):chunk(end)) = distr_maps_segs(i,idx(1));
                elseif chunk(1) > idx(end) % if it is the last element(s)
                    distr_maps_segs(i,chunk(1):chunk(end)) = distr_maps_segs(i,idx(end));
                else % split them (half and half or mark with -3)
                    g1 = floor(counter/2);
                    g2 = rem(counter,2);
                    for g = 1:g1
                        distr_maps_segs(i,chunk(g)) = distr_maps_segs(i,chunk(1)-1);
                        distr_maps_segs(i,chunk(end)+1-g) = distr_maps_segs(i,chunk(end)+1);
                    end
                    if g2 > 0 % if there is a remaining 1 mark it with -3
                        if g1 > 0 % case when there is only 1 zero (thus g1=0)
                            distr_maps_segs(i,chunk(g1)+1) = -3;
                        else
                            distr_maps_segs(i,chunk(1)) = -3;
                        end
                    end
                end
            end    
            k = k + counter;
        end
    end
end

