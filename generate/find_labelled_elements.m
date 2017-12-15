function [labels_empty,labels_def] = find_labelled_elements(labels_map)
%FIND_LABELLED_ELEMENTS returns two vectors, one containing the indeces of
%the labelled data and one containing the indeces of the unlabelled data.

    labels_empty = [];
    labels_def = [];
    for i = 1:length(labels_map)
        if labels_map{i} == -1
            labels_empty = [labels_empty,i];
        else
            labels_def = [labels_def,i];
        end
    end

end

