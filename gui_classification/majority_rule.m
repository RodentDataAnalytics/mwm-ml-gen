function [ class, skipped ] = majority_rule(output_folder, classifications, threshold, varargin)
%MAJORITY_RULE takes a number of classifications and decides the best label
%of each segment based on majority voting.

%If a strategy (including also the undifined ones) has the maximum votes it
%wins. In case of draw then undefined is choosen. If the threshold is
%activated then if case we have a winner then this winner must have also
%collected the amount of votes specified by the threshold or else it is
%markered as undefined.

%INPUT:
% CLASSIFICATIONS: 1xN cell array containing classification_configs objects
% THRESHOLD: a number between 0 and 100 specifying the percentage of
%votes for the winner to be the winner. 
% VARARGIN: is allowed to contain:
    %a) a string: the string must be a valid path in which a 
    %   report will be generate.
    %b) segmentation_config objects in case of different overlaps.
    %c) a cell array containing segmentation_config objects.
    %In case of (b) and (c) at least two segmentation_config objects.
    
%RETURNS:
% CLASS: 1xN+1 cell array containing classification_configs objects. The
%N+1 cell contains the product of this function.
% SKIPPED: 1x2 cell array. The first cell contains an array of indexes of
%the segments that had more than one winners (draw). The second cell 
%contains an array of indexes of the segments that had a winner but they
%remained undifined because of the threshold (if applicant).

%EXAMPLE 1:
%case where we have 6 labels.
%classifications = 1x4, threshold = 60 (meaning 60%);
%If the 10th segment had the following votes for its label: [4 0 1 0 1 0].
%Then: max vote = label 1 with 4 votes, 4 >= (6*60)/100 ? ---> true.
%Thus: 10th segment = label 1.

%EXAMPLE 2:
%case where we have 6 labels.
%classifications = 1x4, threshold = 50 (meaning 50%);
%If the 10th segment had the following votes for its label: [2 2 1 0 1 0].
%Then: max vote = label 1 and 2 with 2 votes.
%Thus: 10th segment = no label and skipped = {[10],[]}.

    class = {0}; 
    skipped = {0};
    
    % sort the classifications according to the number of segments
    maps = zeros(1,length(classifications));
    for i = 1:length(classifications)
        maps(i) = length(classifications{i}.CLASSIFICATION.class_map);
    end
    [~,indexes] = sort(maps,'descend');
    classifications_s = cell(1,length(classifications));
    for i = 1:length(classifications)
        classifications_s(i) = classifications(indexes(i));
    end
    classifications = classifications_s;
    
    % take the class_maps. In case of different lengths take only the same
    % segments and fill the rest with zeros.
    tags = [];
    class_matrix = [];
    for i = 1:length(classifications)
        % collect all the tags
        tags = [tags,unique(classifications{i}.CLASSIFICATION.class_map)];
        try 
            %in case we have the same amount of segments.
            class_matrix = [class_matrix;classifications{i}.CLASSIFICATION.class_map]; 
        catch
            %in case we have the different amount of segments we require
            %segmentation configs objects.
            obj = {};
            k = 1;
            if length(varargin) == 1
                for o = 1:length(varargin{1})
                    if isa(varargin{1}{o},'config_segments')
                        obj{k} = varargin{1}{o};
                        k = k+1;
                    end    
                end
            elseif length(varargin) > 1
                 for o = 1:length(varargin)
                    if isa(varargin{o},'config_segments')
                        obj{k} = varargin{o};
                        k = k+1;
                    end    
                 end     
            end
            if length(obj) < 2
                return
            else
                new_matrix = zeros(1,size(class_matrix,2));
                %find matched segments
                matched = match_segments(obj);
                %keep only the elements of matched segments from class_map
                interest = classifications{i}.CLASSIFICATION.class_map(matched(:,2));
                %assign them to the appropriate slots of the new matrix
                new_matrix(matched(:,1)) = interest;
                class_matrix = [class_matrix;new_matrix];
            end
        end           
    end
    %find unique tags
    tags = unique(tags);
    %exclude the undefined
    %tags = tags(2:end);
    if length(tags) <= 1
        class = {0};
        return;
    end    
    
    % threshold has to be in the range of 0 to 100
    if threshold > 100
        threshold = 100;
    elseif threshold < 0
        threshold = 0;
    end
    
    % perform voting
    class_map = zeros(1,size(class_matrix,2));
    cannot_decide = [];
    threshold_skip = [];
    for i = 1:size(class_matrix,2)
        tmp = zeros(length(tags),1);
        for j = 2:length(tags)
            tmp(j) = sum(class_matrix(:,i)==tags(j));
        end
        [tmp,idx] = sort(tmp,'descend');
        if tmp(1) == tmp(2)
            class_map(i) = 0; %cannot decide
            cannot_decide = [cannot_decide, i];    
        else
            class_map(i) = tags(idx(1));
        end
        %Threshold check: if it is 0 then we skip the threshold
        if threshold > 0
            if tmp(1) >= size(class_matrix,1)*threshold/100
                class_map(i) = tags(idx(1));
            else
                class_map(i) = 0;
                threshold_skip = [threshold_skip, i];
            end
        end
    end    
    
    % generate report file
    majority_rule_report(classifications,cannot_decide,threshold_skip,output_folder);
  
    % generate output
    classifications{end+1} = classifications{1};
    classifications{end}.CLASSIFICATION.class_map = class_map;
    class = classifications;
    skipped = {cannot_decide,threshold_skip};
end