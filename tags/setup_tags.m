function [ obj, labels, t_list_all, t_list ] = setup_tags(obj,fn)
%SETUP_TAGS loads trajectory/segment labels from csv file and assign them
% to our current trajectories/segments
    
    c = 1 ; % used for progrss 
    t_list = tags_list;
    if exist(fn,'file')
        fprintf('Reading labels file...');
        % read the tags file
        tags_data = read_tags(fn);
        % update list of tags if needed
        % t_list_all = update_tags_list(tags_list,tags_data);
        t_list_all = tags_list;
        % exclude tags with no score
        t_list = {};
        k=1;
        for i=1:length(t_list_all)
            if  length(t_list_all{1,i})==4   
                t_list{1,k} = t_list_all{1,i};
                k=k+1;
            end    
        end    
        t_list_ab = cell(1,length(t_list));
        for i=1:length(t_list)
            t_list_ab{i} = t_list{1,i}{1,1};
        end    
        % update "tags" property of trajectory object
        for i=1:length(tags_data)
            index = tags_data{1,i}{1};
            if length(obj.items)>=index
                tags={};
                k=1;
                for j=1:length(tags_data{1,i}{1,2})
                    idx = find(strcmp(t_list_ab,tags_data{1,i}{1,2}{1,j}));
                    tags{1,k} = t_list{1,idx};
                    k=k+1;
                end    
                obj.items(1,index).tags = tags;   
            else
                error('MatchTags:InvalidTrajectory','The input file contains wrong data');
            end
            % display progress
            if i > c*100
                fprintf('%d ', c*100);
                c = c + 1; 
            end  
        end
        fprintf('Labels loaded: %d\n',i); 
    end

    %% THIS CODE CREATES THE LABELS_MAP AND THE LABELS MATRICES USED BY THE ORIGINAL SOFTWARE %%
    labels_map = zeros(length(obj.items),length(t_list));
    for i = 1:length(obj.items)
        for j = 1:length(obj.items(1,i).tags)
            t = obj.items(1,i).tags{1,j}{1,3};
            if t == 0
                labels_map(i,1) = 1;
            else    
                labels_map(i,t+1) = 1;
            end      
        end
    end    
    labels = repmat({-1},1,length(labels_map)); 
    undef_tag_idx = 0;
    if isempty(find(labels_map(:,1)==1)) % if there is no UD
        tag_new_idx = 0:length(t_list)-1;
    else % if there is UD   
        tag_new_idx = 0:length(t_list);
    end    
    for i = 1:length(obj.items)
        class = find(labels_map(i, :) == 1);
        if ~isempty(class)
            % for the 'undefined' class set label idx to zero..
            if class(1) == undef_tag_idx;
                labels{i} = 0;
            else
                % rebase all tags after the undefined index
                labels{i} = arrayfun( @(x) tag_new_idx(x), class);
            end                                       
        end
    end
    % exclude 'UD' tag from the list
    t_list = t_list(2:end);
end