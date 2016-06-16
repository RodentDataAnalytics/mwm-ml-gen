function [animals_ids, animals_trajectories_map] = equalize_groups(groups, animals_ids, animals_trajectories_map, features)
% EQUALIZE_GROUPS asks the user to exclude X number of animals from group
% A or B in order for both groups to have equal number of animals.
% Note: It is activated only if the two groups are not equal.
    
    % General GUI Settings
    units = 'points';
    resizable = 'off';
    fontname = 'Arial';
    fontsize = 11;
    fontunits = 'points';
    
    name = 'Equalize Groups';
    dif = length(animals_ids{1,1}) - length(animals_ids{1,2});

    %% Create Figure
    h.f = figure('units',units,'position',[100,150,240,300],...
             'toolbar','none','menu','none','resize',resizable,...
             'name',name,'NumberTitle','off');
    
    %% Create Labels
    % Texts
    group_1_text = ['Group ',num2str(groups(1)),' contains ',num2str(length(animals_ids{1,1})),' animals'];
    group_2_text = ['Group ',num2str(groups(2)),' contains ',num2str(length(animals_ids{1,2})),' animals'];
    if dif > 0
       dif_text = [num2str(dif),' animals need to be excluded from group ',num2str(groups(1))];
    elseif dif < 0   
       dif_ = abs(dif);
       dif_text = [num2str(dif_),' animals need to be excluded from group ',num2str(groups(2))];
    else
        return
    end   
    % Labels
    h.label_g1 = uicontrol('style','text','units',units,...
                 'position',[5,280,230,15],'string',group_1_text,...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);
    h.label_g2 = uicontrol('style','text','units',units,...
                 'position',[5,265,230,15],'string',group_2_text,...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);         
    h.label_gd = uicontrol('style','text','units',units,...
                 'position',[5,250,230,15],'string',dif_text,...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);
    
    %% Create Listboxes 
    if dif > 0
        ids = animals_ids(1);
    else
        ids = animals_ids(2);
    end     
    h.listbox_1 = uicontrol('style','listbox','units',units,...
                  'position',[40,140,60,100],'string',ids,...
                  'fontname',fontname,'fontsize',fontsize,...
                  'fontunits',fontunits);         
    h.listbox_2 = uicontrol('style','listbox','units',units,...
                  'position',[140,140,60,100],...
                  'fontname',fontname,'fontsize',fontsize,...
                  'fontunits',fontunits);          
         
    %% Create <= => Buttons
    h.right = uicontrol('style','pushbutton','units',units,...
                'position',[105,190,30,20],'string','=>',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@right_callback,h,abs(dif)});
    h.left = uicontrol('style','pushbutton','units',units,...
                'position',[105,170,30,20],'string','<=',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@left_callback,h,abs(dif)},'enable','off');              
            
    %% Create Sort Buttons
    h.speed = uicontrol('style','pushbutton','units',units,...
                'position',[60,110,120,20],'string','Sort by Speed',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',...
                {@sort_callback,h,features(:,3),animals_trajectories_map,animals_ids}); 
    h.pathl = uicontrol('style','pushbutton','units',units,...
                'position',[60,90,120,20],'string','Sort by Path Length',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',...
                {@sort_callback,h,features(:,2),animals_trajectories_map,animals_ids});            
    h.laten = uicontrol('style','pushbutton','units',units,...
                'position',[60,70,120,20],'string','Sort by Latency',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',...
                {@sort_callback,h,features(:,1),animals_trajectories_map,animals_ids});
    h.value = uicontrol('style','pushbutton','units',units,...
                'position',[60,50,120,20],'string','Sort by Value',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@value_callback,h});             
            
    %% Create Exit Buttons
    h.ok = uicontrol('style','pushbutton','units',units,...
                'position',[60,20,60,20],'string','OK',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'enable','off',...
                'callback',{@ok_callback,h,groups, animals_ids, animals_trajectories_map}); 
    h.cancel = uicontrol('style','pushbutton','units',units,...
                'position',[120,20,60,20],'string','Cancel',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@cancel_callback});             
           
    %% Lock the figure
    lock = gcf;
    uiwait(lock);         
            
    %% Callbacks
    function right_callback(varargin)
        S = varargin{3}; %struct
        % get current items of List 1
        currentItems = S.listbox_1.String;
        % get selected of List 1
        selectedItem = S.listbox_1.Value;
        % delete the selected item from List 1
        newItems = currentItems;
        newItems(selectedItem) = [];
        % update List 1
        if S.listbox_1.Value > length(newItems)
            S.listbox_1.Value = S.listbox_1.Value - 1;%select the previous item
        end    
        S.listbox_1.String = newItems;
        % copy the selected item to List 2
        currentItems2 = [S.listbox_2.String; currentItems(selectedItem)];
        % update List 2
        S.listbox_2.String = currentItems2;
        % make the button ghost if enough animals have been excluded
        if length(S.listbox_2.String) == varargin{4}
            set(h.right,'Enable','off');
        end    
        if varargin{4} == length(S.listbox_2.String)
            set(h.ok,'Enable','on');
        else
            set(h.ok,'Enable','off');
        end            
        set(h.left,'Enable','on');
    end    

    function left_callback(varargin)
        S = varargin{3}; %struct
        % get current items of List 2
        currentItems = S.listbox_2.String;
        % get selected of List 2
        selectedItem = S.listbox_2.Value;
        % delete the selected item from List 1
        newItems = currentItems;
        newItems(selectedItem) = [];
        % update List 2
        if S.listbox_2.Value > length(newItems)
            S.listbox_2.Value = S.listbox_2.Value - 1;%select the previous item
        end    
        S.listbox_2.String = newItems;
        % copy the selected item to List 1
        currentItems1 = [S.listbox_1.String; currentItems(selectedItem)];
        % update List 1
        S.listbox_1.String = currentItems1;
        % make the button ghost if enough animals have been excluded
        if length(S.listbox_2.String) > 0;
            set(h.left,'Enable','on');
        else
            set(h.left,'Enable','off');
            S.listbox_2.Value = 1;
        end    
        if varargin{4} == length(S.listbox_2.String)
            set(h.ok,'Enable','on');
        else
            set(h.ok,'Enable','off');
        end            
        set(h.right,'Enable','on');
    end   

    function sort_callback(varargin)
        S = varargin{3}; %struct
        features = varargin{4};
        animals_trajectories_map = varargin{5};
        animals_ids = varargin{6};
        % get current items of List 1
        currentItems = S.listbox_1.String;  
        % convert cell array to char array
        currentItems = cell2mat(currentItems);
        % convert char array to numeric array
        currentItems = str2num(currentItems); 
        average = [];
        if length(animals_ids{1}) > length(animals_ids{2})
            for i = 1:length(currentItems)
                idx = find(animals_ids{1} == currentItems(i));
                f_values = features(animals_trajectories_map{1}(:,idx));
                average = [average mean(f_values)];
            end 
        else
            for i = 1:length(currentItems)
                idx = find(animals_ids{2} == currentItems(i));
                f_values = features(animals_trajectories_map{2}(:,idx));
                average = [average mean(f_values)];
            end
        end    
        % sort the averages
        [~,indexes] = sort(average);
        % sort the currentItems by average indexes
        currentItems = currentItems(indexes);
        % convert to {1xNUM double}
        currentItems = {(currentItems')};
        % update Listbox 1
        set(h.listbox_1,'string',currentItems);                
    end

    function value_callback(varargin)
        S = varargin{3}; %struct
        % get current items of List 1
        currentItems = S.listbox_1.String;  
        % convert cell array to char array
        currentItems = cell2mat(currentItems);
        % convert char array to numeric array
        currentItems = str2num(currentItems);
        % sort the array
        currentItems = sort(currentItems);
        % convert to {1xNUM double}
        currentItems = {(currentItems')};
        % update Listbox 1
        set(h.listbox_1,'string',currentItems);
    end

    function ok_callback(varargin)
        S = varargin{3}; %struct
        groups = varargin{4};
        animals_ids = varargin{5};
        animals_trajectories_map = varargin{6};
        if length(animals_ids{1}) > length(animals_ids{2})
            % for each value of Listbox 2
            for i = 1:length(S.listbox_2.String)
                exclude = str2num(S.listbox_2.String{i});
                % find the index of this id
                idx = find(animals_ids{1} == exclude);
                % remove the column pointed by the index
                animals_ids{1}(:,idx) = [];
                animals_trajectories_map{1}(:,idx) = [];
            end    
        else % if group 2 > group 1
            for i = 1:length(S.listbox_2.String)
                exclude = str2num(S.listbox_2.String{i});
                idx = find(animals_ids{2} == exclude);
                animals_ids{2}(:,idx) = [];
                animals_trajectories_map{2}(:,idx) = [];
            end    
        end  
        % close current figure and continue executing
        try 
            close(gcf); 
        catch
            warning('Window already closed');
        end
    end

    function cancel_callback(varargin)
        % close current figure and continue executing
        try 
            close(gcf); 
        catch
            warning('Window already closed');
        end
    end    
        
end

