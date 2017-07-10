function [ error ] = browse_remove_tag(handles,varargin)
%BROWSE_REMOVE_TAG removes a label from the selected segment
   
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
            %[ error ] = browse_remove_tag(handles,'mode',3);
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
        num_tags = length(selected_tag); %how many cells we should have
        idx = get(handles.available_tags,'Value');        
        selected_tag = selected_tag{idx};
        % find the segment on the labels list
        labels = get(handles.tag_box,'UserData'); 
        if isempty(labels) % if the list is empty return
            error = 0;
            return;
        else
            indexes = labels{1};
            index = find(indexes == seg_num);
            % if the segment is not in the list return
            if isempty(index)
                error = 0;
                return;
            else
                % get all the tags
                label = labels{2}(index,:);
                for i = 1:length(label)
                    % if we have the selected tag remove it
                    if isequal(label{i},selected_tag)
                        % remove it
                        labels{2}{index,i} = [];
                        % remove all empty cells
                        k = labels{2}(index,:);
                        k = k(~cellfun('isempty',k));
                        % reform the length
                        if length(k) < num_tags
                            k{1,num_tags} = [];
                        end
                        for j = 1:length(k)
                            labels{2}{index,j} = k{j};
                        end
                        break;
                    end
                end
            end   
        end
        % refresh the tag_box
        indexes = labels{1};
        index = find(indexes == seg_num);
        tags = {};
        % get the tags if exist
        if ~isempty(index)
            i = 1;
            k = 1;
            while i<=length(labels{2}(index,:))
                if ~isequal(labels{2}{index,i},'');
                    tags{k} = labels{2}{index,i};
                    k = k+1;   
                end
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        elseif isempty(tags)
            % remove empty rows
            tags( all(cellfun(@isempty,tags),2), : ) = [];
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
        % get the selected tag
        selected_tag = get(handles.available_tags,'String'); 
        num_tags = length(selected_tag); %how many cells we should have
        tmp = get(handles.available_tags,'Value');        
        selected_tag = selected_tag{tmp};
        % find the segment on the labels list
        labels = get(handles.listbox,'UserData'); 
        if isempty(labels) % if the list is empty return
            error = 0;
            return;
        else
            indexes = labels{1};
            index = find(indexes == idx);
            % if the segment is not in the list return
            if isempty(index)
                error = 0;
                return;
            else
                % get all the tags
                label = labels{2}(index,:);
                for i = 1:length(label)
                    % if we have the selected tag remove it
                    if isequal(label{i},selected_tag)
                        % remove it
                        labels{2}{index,i} = [];
                        % remove all empty cells
                        k = labels{2}(index,:);
                        k = k(~cellfun('isempty',k));
                        % reform the length
                        if length(k) < num_tags
                            k{1,num_tags} = [];
                        end
                        for j = 1:length(k)
                            labels{2}{index,j} = k{j};
                        end
                        break;
                    end
                end
            end   
        end
        % refresh the listbox
        indexes = labels{1};
        index = find(indexes == idx);
        tags = {};
        % get the tags if exist
        if ~isempty(index)
            i = 1;
            k = 1;
            while i<=length(labels{2}(index,:))
                if ~isequal(labels{2}{index,i},'');
                    tags{k} = labels{2}{index,i};
                    k = k+1;   
                end
                i = i+1;
            end
        end    
        % convert cell to str
        if length(tags) > 1
            tags = strjoin(tags);
        elseif isempty(tags)
            % remove empty rows
            tags( all(cellfun(@isempty,tags),2), : ) = [];
        end    
        set(handles.tag_box,'String',tags); 
        set(handles.listbox,'UserData',labels); 
        error = 0;   
    end    
end

