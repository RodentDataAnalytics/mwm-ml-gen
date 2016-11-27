function [output] = assign_groups(sessions_ids, flag, def_path)
%ASSIGN_GROUPS allows the user to create animal groups or load existed ones

    header = {'Session','ID','Group'};
    if flag == 1
        %use unique ids per session
        sessions = length(unique(sessions_ids(:,1)));
        output = cell(sessions,1);
        ids = cell(1,sessions);
        %data = [session1 id1 ; session1 id2 ; ...]
        data = [];
        for s = 1:sessions
            elements = find(sessions_ids(:,1) == s);
            ids{s} = unique(sessions_ids(elements,2));
            data_ = ones(length(elements),1)*s;
            list_ids = unique(sessions_ids(elements,2));
            data = [data;data_(1:length(list_ids)),list_ids];
        end
        data_ = ones((size(data,1)),1)*-1;
        data = [data,data_];
    else
        %use all ids per session
        %NOT IMPLEMENTED YET
    end    

    % General GUI Settings
    units = 'points';
    resizable = 'off';
    fontname = 'Arial';
    fontsize = 12;
    fontunits = 'points';
    name = 'Animal Groups';

    %% Create Figure
    h.f = figure('units',units,'position',[100,150,320,220],...
             'toolbar','none','menu','none','resize',resizable,...
             'name',name,'NumberTitle','off');
         
    %% Create Table
    ColumnName = {'Session','ID','Group'};
    ColumnWidth = {45,44,45};
    t = uitable('units',units,'Position',[195,55,115,140],'ColumnWidth',ColumnWidth,...
                'fontname',fontname,'fontsize',fontsize,'fontunits',fontunits,...
                'ColumnName',ColumnName,'RowName',[],'data',data);      
                       
    %% Create Listbox Section
    h.label_top = uicontrol('style','text','units',units,...
                 'position',[9,195,90,15],'string','Animal IDs',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);
             
    h.listbox_1 = uicontrol('style','listbox','units',units,...
              'position',[10,55,80,140],'string',ids{1},...
              'fontname',fontname,'fontsize',fontsize,...
              'fontunits',fontunits, 'min',1,'max',10);
          
    h.label_bottom = uicontrol('style','text','units',units,...
                 'position',[13,35,45,15],'string','Session:',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);             
    h.label_bottom_num = uicontrol('style','text','units',units,...
             'position',[63,35,20,15],'string','1',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits);     
         
    h.previous = uicontrol('style','pushbutton','units',units,...
             'position',[17,15,30,20],'string','<=',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@previous_callback});        
    h.next = uicontrol('style','pushbutton','units',units,...
                'position',[52,15,30,20],'string','=>',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@next_callback});      

    %% Create Assign Group
    h.label_num = uicontrol('style','text','units',units,...
                 'position',[105,180,75,15],'string','Group Number',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);    
    h.text_num = uicontrol('style','edit','units',units,...
                 'position',[105,165,75,15],'string','',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);  
             
    h.assign = uicontrol('style','pushbutton','units',units,...
             'position',[111,140,63,20],'string','Assign',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@assign_callback});    

    %% Create Save - Load
    h.save = uicontrol('style','pushbutton','units',units,...
             'position',[103,110,40,20],'string','Save',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@save_callback,def_path});  
    h.load = uicontrol('style','pushbutton','units',units,...
             'position',[143,110,40,20],'string','Load',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@load_callback,def_path});         
         
    %% Create Exit
    h.ok = uicontrol('style','pushbutton','units',units,...
                'position',[98,15,45,25],'string','OK',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@ok_callback,def_path}); 
    h.cancel = uicontrol('style','pushbutton','units',units,...
                'position',[143,15,45,25],'string','Cancel',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@cancel_callback});      
            
    %% CloseRequestFcn
    set(h.f,'CloseRequestFcn','my_exit_req');
    %% Lock the figure
    %lock = gcf;
    uiwait(h.f);         
            
    %% Exit Function
    function my_exit_req(varargin)
        fig = findobj(gcf,'Name','Animal Groups');
        if isequal(get(fig,'waitstatus'),'waiting')
            uiresume(fig);
            delete(fig);
        else
            delete(fig);
        end
    end
    
    %% Callback Functions
    function previous_callback(hObject, eventdata)
        idx = str2double(get(h.label_bottom_num,'string'));
        if idx == 1
            return;
        end
        set(h.listbox_1,'value',1);
        set(h.listbox_1,'string',ids{idx-1});
        set(h.label_bottom_num,'string',idx-1);
    end
    function next_callback(hObject, eventdata)
        idx = str2double(get(h.label_bottom_num,'string'));
        if idx >= length(ids) 
            return;
        end
        set(h.listbox_1,'value',1);
        set(h.listbox_1,'string',ids{idx+1});
        set(h.label_bottom_num,'string',idx+1); 
    end

    function assign_callback(hObject, eventdata)
        group = str2double(get(h.text_num,'string'));
        if ~isempty(group)  
            if isnan(group) || length(group) > 1
                errordlg('Animal Groups need to have numeric and larger than zero values.','Wrong Input');
                return
            elseif group <= 0
                errordlg('Animal Groups need to have numeric and larger than zero values.','Wrong Input');
                return
            end
        elseif isempty(group)
            errordlg('Animal Groups need to have numeric and larger than zero values.','Wrong Input');
            return
        end
        % get selected ids (indexes)
        selection = get(h.listbox_1,'value');
        % get selected ids (values)
        tmp_ids = get(h.listbox_1,'string');
        % equalize cells
        tmp_ids = cellstr(tmp_ids);
        maxSize = max(cellfun(@(x)size(x,2),tmp_ids));
        for i = 1:size(tmp_ids,1)
            if length(tmp_ids{i}) < maxSize
                adding = maxSize - length(tmp_ids{i});
                for j = 1:adding
                    tmp_ids{i} = [tmp_ids{i} ' '];
                end    
            end
        end  
        % assign group to the selected ids
        ses = str2double(get(h.label_bottom_num,'string'));
        %get ids of the specific session
        tmp_ids = find(data(:,1) == ses);
        for i = 1:length(selection)
            data(tmp_ids(selection(i)),3) = group;
        end
        % update the gui
        set(t,'data',data);
    end

    function save_callback(hObject, eventdata, def_path)
        Table = array2table(data,'VariableNames',header);
        def_path = char_project_path(def_path);
        % propose file name and create file
        time = fix(clock);
        formatOut = 'yyyy-mmm-dd-HH-MM';
        time = datestr((time),formatOut);
        % propose: project's results folder
        [file,gpath] = uiputfile('*.csv','Save animal groups',fullfile(def_path,'results',strcat('groups_',time)));
        if gpath==0
            return
        end    
        %fid = fopen(fullfile(gpath,file),'w');
        %fclose(fid);      
        % save to the new csv file the tmp_data
        writetable(Table,fullfile(gpath,file),'WriteVariableNames',1);
    end

    function load_callback(hObject, eventdata, def_path)
        def_path = char_project_path(def_path);
        % ask for labels csv file
        [file,gpath] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels',def_path);
        if gpath == 0
            return;
        end 
        file = strcat(gpath,file);  
        % check if file is correct
        fid = fopen(file);
        tmp_header = textscan(fid,'%s %s %s',1,'Delimiter',',');
        fclose(fid);
        for i = 1:length(tmp_header)
            if ~isequal(header{i},tmp_header{i}{1})
                errordlg('Cannot load file.','File error');
                return;
            end
        end    
        % read the file
        fmt = repmat('%s ',[1,length(tmp_header)]);
        fid = fopen(file);
        tmp_data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',','HeaderLines',1);
        fclose(fid);   
        data = str2double(tmp_data{1});
        % update the gui
        set(t,'data',data);
    end

    function ok_callback(hObject, eventdata, def_path)
        def_path = char_project_path(def_path);
        ses = unique(data(:,1));
        unique_g = sort(unique(data(:,3)));
        gap_g = find(data(:,3) == -1);
        if ~isempty(gap_g)
            %generate a number which is not used as an animal group
            generate = -1;
            for i = 1:unique_g
                if unique_g(i) ~= i
                    generate = i;
                end
            end    
            if generate == -1
                generate = max(unique_g) + 1;
                if generate == 0
                    generate = 1;
                end
            end    
            str = ['Some animals are not assigned to groups. These animals will automatically be assigned to group ' num2str(generate) '. Do you wish to continue?'];
            choice = questdlg(str,'Un-grouped animals','Yes','No','No');
            switch choice
                case 'Yes'
                    data(gap_g,3) = generate;
                case 'No'
                    return;
            end
        end    
        %form the output    
        for i = 1:length(ses)
            tmp = find(data(:,1) == i);
            output{i} = data(tmp,2:3);
        end   
        %create the CSV file also
        Table = array2table(data,'VariableNames',header);
        writetable(Table,fullfile(def_path,'settings','animal_groups.csv'),'WriteVariableNames',1);        
        %close this figure
        my_exit_req;
    end

    function cancel_callback(varargin)     
        my_exit_req;
    end
end

