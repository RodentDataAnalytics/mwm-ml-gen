function [ obj, LABELLING_MAP, ALL_TAGS, CLASSIFICATION_TAGS ] = setup_tags(obj,fn)
%SETUP_TAGS loads trajectory/segment labels from csv file and assign them
% to the current trajectories/segments

    if ~exist(fn,'file')
        obj = '';
        LABELLING_MAP = '';
        ALL_TAGS = '';
        CLASSIFICATION_TAGS = '';
        return;
    end
    
    % find the project path and load the tags
    ppath = fileparts(fn);
    ppath = fileparts(ppath);
    [~,tags] = parse_tags(fullfile(ppath,'settings','tags.txt'));
    % see if we have trajectories or segments
    [~,name,~] = fileparts(fn);
    name = strsplit(name,'_');
    if isequal(name{3},'0')
        name = 'T';
    else
        name = 'S';
    end
    
    % Make the ALL_TAGS and CLASSIFICATION_TAGS
    tags(1,:) = [];
    ALL_TAGS = cell(1,size(tags,1));
    CLASSIFICATION_TAGS = {};
    for i = 1:length(ALL_TAGS)
        c = cell(1,4);
        c{1,1} = tags{i,1}; %abbreviation
        c{1,2} = tags{i,2}; %description
        c{1,3} = str2num(tags{i,3}); %id
        c{1,4} = tags{i,9}; %public/traj/seg
        ALL_TAGS{1,i} = c;
        if isequal(tags{i,9},'public')
            CLASSIFICATION_TAGS = [CLASSIFICATION_TAGS, {c}];
        elseif isequal(name,'T') && isequal(tags{i,9},'trajectory')
            CLASSIFICATION_TAGS = [CLASSIFICATION_TAGS, {c}];
        elseif isequal(name,'S') && isequal(tags{i,9},'segment')
            CLASSIFICATION_TAGS = [CLASSIFICATION_TAGS, {c}];
        end
    end
    c{1,1} = 'UD';
    c{1,2} = 'Undefined';
    c{1,3} = 0;
    c{1,4} = 'public';
    ALL_TAGS = [{c},ALL_TAGS];
    
    % Make the LABELLING MAP
    if isequal(name,'T') 
        if isempty(obj.parent) %if 'my_trajectories' is loaded
            len = length(obj.items);
        else                   %if segmentation obj is loaded
            len = length(obj.parent.items);
        end
    elseif isequal(name,'S') 
        len = length(obj.items);
    end   
    LABELLING_MAP = -1*ones(1,len);
    LABELLING_MAP = num2cell(LABELLING_MAP);
    tags_data = read_tags(fn); % cell(1) = index, cell(2) = labels
    for i = 1:length(tags_data)
        idx = tags_data{i}{1}; %get the element index
        tmp = zeros(1,length(CLASSIFICATION_TAGS));
        for j = 1:length(tags_data{i}{2})
            labels = tags_data{i}{2}{j}; %get the element first label
            for k = 1:length(CLASSIFICATION_TAGS) %find the label id
                if isequal(labels,CLASSIFICATION_TAGS{k}{1})
                    tag_idx = CLASSIFICATION_TAGS{k}{3};
                    break;
                end
            end
            tmp(1,tag_idx) = 1;
        end
        %assign to this 'idx' element the 'tag_idx'
        tag_idx = find(tmp==1);
        LABELLING_MAP{idx} = tag_idx;
    end
end
            
%% OLD CODE
%function [ obj, labels, t_list_all, t_list ] = setup_tags(obj,fn)
%     t_list = tags_list;
%     if exist(fn,'file')
%         fprintf('Reading labels file...');
%         % read the tags file
%         tags_data = read_tags(fn);
%         % update list of tags if needed
%         % t_list_all = update_tags_list(tags_list,tags_data);
%         t_list_all = tags_list;
%         % exclude tags with no score
%         t_list = {};
%         k=1;
%         for i=1:length(t_list_all)
%             if  length(t_list_all{1,i})==4   
%                 t_list{1,k} = t_list_all{1,i};
%                 k=k+1;
%             end    
%         end    
%         t_list_ab = cell(1,length(t_list));
%         for i=1:length(t_list)
%             t_list_ab{i} = t_list{1,i}{1,1};
%         end    
%         % update "tags" property of trajectory object
%         for i=1:length(tags_data)
%             index = tags_data{1,i}{1};
%             if length(obj.items)>=index
%                 tags={};
%                 k=1;
%                 for j=1:length(tags_data{1,i}{1,2})
%                     idx = find(strcmp(t_list_ab,tags_data{1,i}{1,2}{1,j}));
%                     tags{1,k} = t_list{1,idx};
%                     k=k+1;
%                 end    
%                 obj.items(1,index).tags = tags;   
%             else
%                 error('MatchTags:InvalidTrajectory','The input file contains wrong data');
%             end
%         end
%         fprintf('Labels: %d\n',i); 
%     end
% 
%     %% THIS CODE CREATES THE LABELS_MAP AND THE LABELS MATRICES USED BY THE ORIGINAL SOFTWARE %%
%     labels_map = zeros(length(obj.items),length(t_list));
%     for i = 1:length(obj.items)
%         for j = 1:length(obj.items(1,i).tags)
%             t = obj.items(1,i).tags{1,j}{1,3};
%             if t == 0
%                 labels_map(i,1) = 1;
%             else    
%                 labels_map(i,t+1) = 1;
%             end      
%         end
%     end    
%     labels = repmat({-1},1,length(labels_map)); 
%     undef_tag_idx = 0;
%     if isempty(find(labels_map(:,1)==1)) % if there is no UD
%         tag_new_idx = 0:length(t_list)-1;
%     else % if there is UD   
%         tag_new_idx = 0:length(t_list);
%     end    
%     for i = 1:length(obj.items)
%         class = find(labels_map(i, :) == 1);
%         if ~isempty(class)
%             % for the 'undefined' class set label idx to zero..
%             if class(1) == undef_tag_idx;
%                 labels{i} = 0;
%             else
%                 % rebase all tags after the undefined index
%                 labels{i} = arrayfun( @(x) tag_new_idx(x), class);
%             end                                       
%         end
%     end
%     % exclude 'UD' tag from the list
%     t_list = t_list(2:end);
% end