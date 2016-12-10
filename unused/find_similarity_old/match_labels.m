function [data,marked] = match_labels(objects,labels,varargin)
%MATCH_LABELS

    [merged,~] = match_segments(objects,varargin);
    try
        % get the labels
        fid = fopen(labels);
        f_line = fgetl(fid);
        fclose(fid);
        num_cols = length(find(f_line==','))+1;
        fmt = repmat('%s ',[1,num_cols]);
        fid = fopen(labels);
        tmp_data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
        tmp_data = tmp_data{1};
        fclose(fid);
        % check if we have a header and delete it
        header = [];
        if isempty(str2num(tmp_data{1,1}))
            header = tmp_data(1,:);
            tmp_data(1,:)=[];
        end    
    catch
        data = [];
        marked = [];
        return
    end    
    
    % get the first column and turn it to array of doubles
    seg_idx = zeros(length(tmp_data),1);
    for i = 1:length(tmp_data)
        seg_idx(i) = str2num(tmp_data{i});
    end   

%     % sort and see to which segmentation it refers to
%     seg_idx = sort(seg_idx);
%     pointer = 0;
%     for i = 1:length(segmentations)
%         if length(segmentations{i}.FEATURES_VALUES_SEGMENTS) <= seg_idx(end)
%             pointer = i;
%         end
%     end
%     if pointer = 0
%         return
%     end  

    % only 2 segmentations (the first one will have the most segments)
    if ~iscell(merged)
        data = cell(size(tmp_data,1),size(tmp_data,2));
        marked = [];
        for i = 1:length(seg_idx)
            tmp = find(merged(:,1) == seg_idx(i));
            if isempty(tmp)
                marked = [marked;seg_idx(i)];
                continue;
            end    
            matched = merged(tmp,2);
            data{i,1} = num2str(matched);
            for j = 2:size(tmp_data,2)
                data{i,j} = tmp_data{i,j};
            end    
        end
        data = [header;data];
        % delete empty rows (only in case we have 'marked' segments);
        data(all(cellfun(@isempty,data),2), : ) = [];
        % save to file
        data = cell2table(data);
        [path,name,ext] = fileparts(labels);
        full_path = strcat(path,'/',name,'_2',ext);
        writetable(data,full_path,'WriteVariableNames',0);
    end    

end

