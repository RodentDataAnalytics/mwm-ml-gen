function [ w ] = class_weights(distr_maps_segs,length_map,tags)
%CLASS_WEIGHTS computes the strategies weights
    
    % Detect the maximum nember of continuous segments for each strategy
    maximum_sequences = zeros(4,tags);
    for i = 1:tags %for each strategy   
        max_sequence = 0;
        for rows = 1:size(distr_maps_segs,1) %for each row
            %make a vector with length the length of the row,
            %fill it with zeros and fill with ones the slots
            %that fulfill find(distr_maps_segs(rows,:)==i)
            index_vector = zeros(1,size(distr_maps_segs,2));
            values = find(distr_maps_segs(rows,:)==i);
            index_vector(values) = 1;
            counter = 0;
            for r = 1:length(index_vector) %for each slot
                if index_vector(r) == 0
                    if counter > max_sequence
                        max_sequence = counter;
                        row_s = rows;
                        start_s = r-counter;
                        end_s = r-1;
                    end
                    counter = 0;
                    continue;
                else
                    counter = counter + 1;
                end
            end
        end  
        maximum_sequences(1,i) = max_sequence; %sequence counter
        maximum_sequences(2,i) = row_s; %sequence row
        maximum_sequences(3,i) = start_s; %sequence start
        maximum_sequences(4,i) = end_s; %sequence end
    end

    % Calculate the maximum length of continuous segments for each strategy  
    Lmax = zeros(1,tags);
    for i = 1:8
        rowi = maximum_sequences(2,i);
        starti = maximum_sequences(3,i);
        endi = maximum_sequences(4,i);
        Lmax(1,i) = sum(length_map(rowi,starti:endi));
    end

    % Calculate the weights
    Lmax_ = ones(1,length(Lmax))*max(Lmax);
    w = Lmax_ ./ Lmax;
end

