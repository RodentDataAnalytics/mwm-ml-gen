function [ error ] = browse_add_tag(handles,varargin)
%BROWSE_ADD_TAG adds a label to the selected segment/trajectory

    error = 1;
    % Check what kind of object is loaded
    mode = get(handles.plotter,'UserData');
    t = get(handles.available_tags,'Value'); 
    if isempty(mode) || t == 1
        return;
    end    
    
%     for i = 1:length(varargin) % runs if mode=1 and trajectory is selected
%         if iequal(varargin{i},'mode')
%             mode = varargin{i+1};
%         end
%     end
    
    %% SEGMENTATION OBJECT LOADED
    if mode == 1
        % if it is the trajectory return
        if get(handles.listbox,'Value') == 1;
            %[ error ] = browse_add_tag(handles,'mode',3);
            return;
        end  
        % get the # of the segment
        seg_num = get(handles.segment_info, 'data');
        if isempty(seg_num(1))
            return;
        end    
        seg_num = seg_num(1);
        % get the selected tag
        selected_tag = get(handles.available_tags,'String'); 
        num_tags = length(selected_tag);
        idx = get(handles.available_tags,'Value');        
        selected_tag = selected_tag{idx};
        % find the segment on the labels list
        labels = get(handles.tag_box,'UserData'); 
        if isempty(labels) % if the list is empty create a new record
            labels = cell(1,2);
            labels{1} = seg_num;
            labels{2} = cell(1,num_tags);
            labels{2}{1} = selected_tag;
        else
            indexes = labels{1};
            index = find(indexes == seg_num);
            % if the segment is not in the list create a new record
            if isempty(index)
                labels{1} = [labels{1};seg_num];
                new = cell(1,num_tags);
                new{1} = selected_tag;
                labels{2} = [labels{2};new];
            else
                % get all the tags
                label = labels{2}(index,:);
                for i = 1:length(label)
                    % if we already have the selected tag return
                    if isequal(label{i},selected_tag)
                        return
                    % if we do not add it
                    elseif isequal(label{i},'')
                        labels{2}{index,i} = selected_tag;
                        break;
                    end
                end
            end   
        end
        % refresh the tag_box
        indexes = labels{1};
        index = find(indexes == seg_num);
        tags = '';
        % get the tags if exist
        if ~isempty(index)
            i = 1;
            while i<=length(labels{2}(index,:)) &&  ~isequal(labels{2}{index,i},'');
                tags{i} = labels{2}{index,i};
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        end    
        set(handles.tag_box,'String',tags); 
        set(handles.tag_box,'UserData',labels); 
        error = 0;
        
        
    %% CLASSIFICATION OBJECT LOADED    
    elseif mode == 2
        %...
        
    elseif mode == 3 || mode == 4
        idx = get(handles.navigator,'String');
        try
            if isempty(str2num(idx))
                return
            end  
        catch
            return
        end  
        idx = str2num(idx);
        selected_tag = get(handles.available_tags,'String'); 
        num_tags = length(selected_tag);
        tmp = get(handles.available_tags,'Value');        
        selected_tag = selected_tag{tmp};
        % find the segment on the labels list
        labels = get(handles.listbox,'UserData'); 
        if isempty(labels) % if the list is empty create a new record
            labels = cell(1,2);
            labels{1} = idx;
            labels{2} = cell(1,num_tags);
            labels{2}{1} = selected_tag;
        else
            indexes = labels{1};
            index = find(indexes == idx);
            % if the segment is not in the list create a new record
            if isempty(index)
                labels{1} = [labels{1};idx];
                new = cell(1,num_tags);
                new{1} = selected_tag;
                labels{2} = [labels{2};new];
            else
                % get all the tags
                label = labels{2}(index,:);
                for i = 1:length(label)
                    % if we already have the selected tag return
                    if isequal(label{i},selected_tag)
                        return
                    % if we do not add it
                    elseif isequal(label{i},'')
                        labels{2}{index,i} = selected_tag;
                        break;
                    end
                end
            end   
        end
        % refresh the listbox
        indexes = labels{1};
        index = find(indexes == idx);
        tags = '';
        % get the tags if exist
        if ~isempty(index)
            i = 1;
            while i<=length(labels{2}(index,:)) &&  ~isequal(labels{2}{index,i},'');
                tags{i} = labels{2}{index,i};
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        end    
        set(handles.tag_box,'String',tags); 
        set(handles.listbox,'UserData',labels); 
        error = 0;        
    end    
end

