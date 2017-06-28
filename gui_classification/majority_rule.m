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

    REPORT = 1;
    EXCLUDE_UNDEFINED = 1;
    CROSS_VALIDATE = 0;
    for i = 1:length(varargin)
        if isequal(varargin{i},'REPORT')
            REPORT = varargin{i+1};
        elseif isequal(varargin{i},'EXCLUDE_UNDEFINED')
            EXCLUDE_UNDEFINED = varargin{i+1};
        elseif isequal(varargin{i},'CROSS_VALIDATE')
            CROSS_VALIDATE = varargin{i+1};
        end
    end

    class = {0};
    skipped = {0};
    
    if ~CROSS_VALIDATE 
        % Get the class_map and the unique tags of every classifier
        class_matrix = [];
        tags = [];
        cl = [];
        for i = 1:length(classifications)
            class_matrix = [class_matrix;classifications{i}.CLASSIFICATION.class_map];
            tags = [tags,unique(classifications{i}.CLASSIFICATION.class_map)];
            cl = [cl,classifications{i}.DEFAULT_NUMBER_OF_CLUSTERS];
        end
        tags = unique(tags);

        if length(tags) <= 1 
            return;
        end
    else
        class_matrix = classifications;
        tags = unique(class_matrix);
    end
    
    % threshold has to be in the range of 0 to 100
    if threshold > 100
        threshold = 100;
    elseif threshold < 0
        threshold = 0;
    end
    
    if EXCLUDE_UNDEFINED
        sj = 2;
    else
        sj = 1;
    end
    
    % perform voting
    class_map = zeros(1,size(class_matrix,2));
    cannot_decide = [];
    threshold_skip = [];
    for i = 1:size(class_matrix,2)
        tmp = zeros(length(tags),1);
        for j = sj:length(tags)
            tmp(j) = sum(class_matrix(:,i)==tags(j));
        end
        [tmp,idx] = sort(tmp,'descend');
        if length(tmp) > 1
            if tmp(1) == tmp(2)
                class_map(i) = 0; %cannot decide
                cannot_decide = [cannot_decide, i]; 
            else
                class_map(i) = tags(idx(1));
            end
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
    
    if ~CROSS_VALIDATE 
        % generate report file
        if REPORT
            majority_rule_report(classifications,cannot_decide,threshold_skip,output_folder);
        end

        % generate output
        classifications{end+1} = classifications{1};
        classifications{end}.CLASSIFICATION.class_map = class_map;
        classifications{end}.DEFAULT_NUMBER_OF_CLUSTERS = cl;
        class = classifications;
        skipped = {cannot_decide,threshold_skip};
    else
        class = class_map;
    end
end