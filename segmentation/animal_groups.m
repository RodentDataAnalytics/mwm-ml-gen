function [ groups_data ] = animal_groups( paths, id_field, sessions )
%ANIMAL_GROUPS allows the user to create animal groups or load existed
%ones.
% Note: It is activated only if the user presses 'Yes' on the quest dialog
% 'Would you like to assign animals to groups?' which is prompted when the
% button 'Segmentantion' is pressed.

    % General GUI Settings
    units = 'points';
    resizable = 'off';
    fontname = 'Arial';
    fontsize = 11;
    fontunits = 'points';
    
    name = 'Animal Groups';
    
    data_path = paths{1};
    out_path = paths{2};
    session_ = '1';
    
    % Read all the trajectory files and parse the animal ids
    animal_ids = parse_data_simplified(data_path, id_field, sessions);
	if isempty(animal_ids)
		groups_data = [];
	end	
    
    % Create a temp file and populate it with the animal ids
    temp_path = create_temp_groups_file(sessions, animal_ids);

    %% Create Figure
    h.f = figure('units',units,'position',[100,150,320,220],...
             'toolbar','none','menu','none','resize',resizable,...
             'name',name,'NumberTitle','off','CloseRequestFcn',{@cancel_callback,temp_path});
         
         
    %% Create Table
    % read all the data from temp file
    fid = fopen(temp_path);
    header = fgetl(fid);
    fclose(fid);
    num_cols = length(find(header==','))+1;
    fmt = repmat('%s ',[1,num_cols]);
    fid = fopen(temp_path);
    data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
    Table = data{1};
    fclose(fid);
    % columns width
    col_w = zeros(1,size(Table,2));
    col_w = cell(size(col_w));
    c = cellfun('isempty',col_w);
    col_w(c) = {40};    
    % create the table
    t = uitable('units',units,'Position',[195,55,115,140],'columnwidth',col_w,...
                'fontname',fontname,'fontsize',fontsize,'fontunits',fontunits,...
                'ColumnName',Table(1,1:end),'RowName',[],'data',Table(2:end,:));      
                     
    
    %% Create Listbox Section
    h.label_top = uicontrol('style','text','units',units,...
                 'position',[9,195,90,15],'string','Animal IDs',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);
             
    h.listbox_1 = uicontrol('style','listbox','units',units,...
              'position',[10,55,80,140],'string',animal_ids{1},...
              'fontname',fontname,'fontsize',fontsize,...
              'fontunits',fontunits, 'min',1,'max',10);
          
    h.label_bottom = uicontrol('style','text','units',units,...
                 'position',[13,35,45,15],'string','Session:',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);             
    h.label_bottom_num = uicontrol('style','text','units',units,...
             'position',[63,35,20,15],'string',session_,...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits);     
         
    h.previous = uicontrol('style','pushbutton','units',units,...
             'position',[17,15,30,20],'string','<=',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@previous_callback,h,animal_ids,temp_path});        
    h.next = uicontrol('style','pushbutton','units',units,...
                'position',[52,15,30,20],'string','=>',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@next_callback,h,animal_ids,temp_path});      

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
             'fontunits',fontunits,'callback',{@assign_callback,h,temp_path,t});    

    %% Create Save - Load
    h.save = uicontrol('style','pushbutton','units',units,...
             'position',[103,110,40,20],'string','Save',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@save_callback,h,animal_ids,temp_path});  
    h.load = uicontrol('style','pushbutton','units',units,...
             'position',[143,110,40,20],'string','Load',...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits,'callback',{@load_callback,h,animal_ids,temp_path,t});         
         
    %% Create Exit
    h.ok = uicontrol('style','pushbutton','units',units,...
                'position',[98,15,45,25],'string','OK',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,...
                'callback',{@ok_callback,h,animal_ids,temp_path,t}); 
    h.cancel = uicontrol('style','pushbutton','units',units,...
                'position',[143,15,45,25],'string','Cancel',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@cancel_callback,temp_path});      
            

    groups_data = []; % if empty is returned then cancel/X was pressed       
    %% Lock the figure
    lock = gcf;
    uiwait(lock);         
            
    %% Callback Functions
    function previous_callback(varargin)
        animal_ids = varargin{4};
        temp_path = varargin{5};
        idx = get(h.label_bottom_num,'string');
        idx = str2num(idx);
        if idx == 1
            return
        else
            % open the file and parse all the data
            fid = fopen(temp_path);
            header = fgetl(fid);
            fclose(fid);
            fid = fopen(temp_path);
            num_cols = length(find(header==','))+1;
            fmt = repmat('%s ',[1,num_cols]);
            data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
            Table = data{1};
            fclose(fid);   
            % take the appropriate id column based on the session
            temp_data = Table(2:end,idx+idx-3:idx+idx-2);     
            % remove empty cells
            temp_data = temp_data(~cellfun('isempty',temp_data)); 
            set(h.listbox_1,'value',1);
            set(h.listbox_1,'string',temp_data);
            set(h.label_bottom_num,'string',idx-1);
        end    
    end
    function next_callback(varargin)
        animal_ids = varargin{4};
        temp_path = varargin{5};
        idx = get(h.label_bottom_num,'string');
        idx = str2num(idx);
        if idx >= length(animal_ids) 
            return
        else
            % open the file and parse all the data
            fid = fopen(temp_path);
            header = fgetl(fid);
            fclose(fid);
            fid = fopen(temp_path);
            num_cols = length(find(header==','))+1;
            fmt = repmat('%s ',[1,num_cols]);
            data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
            Table = data{1};
            fclose(fid);   
            % take the appropriate id column based on the session
            temp_data = Table(2:end,idx+idx+1:idx+idx+2);     
            % remove empty cells
            temp_data = temp_data(~cellfun('isempty',temp_data)); 
            set(h.listbox_1,'value',1);
            set(h.listbox_1,'string',temp_data);
            set(h.label_bottom_num,'string',idx+1);
        end   
    end


    function assign_callback(varargin)
        group = get(h.text_num,'string');
        try
            if isempty(group)
            else    
                group = str2num(group);
                if isempty(group) || length(group) > 1
                    errordlg('Animal Groups need to have numeric values.','Wrong Input');
                    return
                end 
            end    
        catch ME
            errordlg('Animal Groups need to have numeric values.','Wrong Input');
            return
        end    
        % get selected ids (indexes)
        selection = get(h.listbox_1,'value');
        % get selected ids (values)
        ids = get(h.listbox_1,'string');
        % equalize cells
        ids = cellstr(ids);
        maxSize = max(cellfun(@(x)size(x,2),ids));
        for i = 1:size(ids,1)
            if length(ids{i}) < maxSize
                adding = maxSize - length(ids{i});
                for j = 1:adding
                    ids{i} = [ids{i} ' '];
                end    
            end
        end  
        % get selected session
        idx = get(h.label_bottom_num,'string');
        idx = str2num(idx);
        % get user defined group
        group = get(h.text_num,'string');
        group = str2num(group);
        % read all the data from temp file
        temp_path = varargin{4};
        fid = fopen(temp_path);
        header = fgetl(fid);
        fclose(fid);
        num_cols = length(find(header==','))+1;
        fmt = repmat('%s ',[1,num_cols]);
        fid = fopen(temp_path);
        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
        Table = data{1};
        fclose(fid);   
        % take the appropriate id column based on the session
        temp_data = Table(2:end,idx+idx-1);
        % remove empty cells
        temp_data = temp_data(~cellfun('isempty',temp_data));   
        % equalize cells
        maxSize = max(cellfun(@(x)size(x,2),temp_data));
        for i = 1:size(temp_data,1)
            if length(temp_data{i}) < maxSize
                adding = maxSize - length(temp_data{i});
                for j = 1:adding
                    temp_data{i} = [temp_data{i} ' '];
                end    
            end
        end    
        temp_data = cell2mat(temp_data);
        temp_data = str2num(temp_data);
        % assign group to the selected ids
        if length(selection) == 1
            a = find(temp_data == str2num(ids{selection}));
            Table{a+1,idx+idx} = num2str(group);
        else    
            for i = 1:length(selection)
                a = find(temp_data == str2num(ids{selection(i)}));
                % a+1 because we have the header
                Table{a+1,idx+idx} = num2str(group);
            end 
        end
        % update the gui
        set(t,'data',Table(2:end,:));
        % update the temp file
        Table = cell2table(Table);
        fid = fopen(temp_path);
        writetable(Table,temp_path,'WriteVariableNames',0);
        fclose(fid); 
    end


    function save_callback(varargin)
        % read all the data from temp file
        temp_path = varargin{5};
        fid = fopen(temp_path);
        header = fgetl(fid);
        fclose(fid);
        num_cols = length(find(header==','))+1;
        fmt = repmat('%s ',[1,num_cols]);
        fid = fopen(temp_path);
        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
        Table = data{1};
        fclose(fid);   
        % propose file name and create file
        time = fix(clock);
        formatOut = 'yyyy-mmm-dd-HH-MM';
        time = datestr((time),formatOut);
        [file,path] = uiputfile('*.csv','Save animal groups',strcat('groups_',time));
        fid = fopen(strcat(path,file),'w');
        fclose(fid);      
        % save to the new csv file the tmp_data
        tmp_data2 = cell2table(Table);
        writetable(tmp_data2,strcat(path,file),'WriteVariableNames',0);        
    end
    function load_callback(varargin)
        % ask for labels csv file
        [file,path] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing segment labels');
        if path == 0
            return;
        end 
        % check if file is ok
        file = strcat(path,file);
        if ~exist(file, 'file') == 2
            errordlg('Error loading the labels file.');
            return
        end     
        % copy file data to temp_file
        fid = fopen(file);
        header = fgetl(fid);
        fclose(fid);
        num_cols = length(find(header==','))+1;
        fmt = repmat('%s ',[1,num_cols]);
        fid = fopen(file);
        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
        Table = data{1};
        fclose(fid);           
        temp_path = varargin{5};
        % update the gui
        set(t,'data',Table(2:end,:));
        % update the temp file
        tmp_data = cell2table(Table);
        writetable(tmp_data,temp_path,'WriteVariableNames',0); 
    end

    function ok_callback(varargin)
        animal_ids = varargin{4};
        temp_path = varargin{5};
        fid = fopen(temp_path);
        header = fgetl(fid);
        fclose(fid);
        num_cols = length(find(header==','))+1;
        fmt = repmat('%s ',[1,num_cols]);
        fid = fopen(temp_path);
        data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
        Table = data{1};
        user_groups = {};
        empty_g = 0;
        k = 2;
        for i = 1:num_cols/2
            for j = 1:size(animal_ids{i},2)
                if isempty(Table{j+1,k})
                    empty_g = 1;
                end    
                user_groups = [user_groups str2num(Table{j+1,k})];
            end
            k = k+2;
        end  
        if empty_g
            user_groups = unique(cell2mat(user_groups));
            max_g = max(user_groups);
            generated = [];
            for i = 1:max_g
                if ~ismember(user_groups(i),i)
                    generated = i;
                    break;
                end
            end  
            if isempty(generated)
                generated = max_g+1;
                % no groups are assigned
                if isempty(generated)
                    generated = 1;
                end    
            end    
            str = ['Some animals are not assigned to groups. These animals will automatically be assigned to group ' num2str(generated) '. Do you wish to continue?'];
            choice = questdlg(str,'Un-grouped animals','Yes','No','No');
            switch choice
                case 'Yes'
                    k = 2;
                    for i = 1:num_cols/2
                        for j = 1:size(animal_ids{i},2)
                            if isempty(Table{j+1,k})
                                Table{j+1,k} = generated;
                            end    
                        end
                        k = k+2;
                    end  
                case 'No'
                    return
            end            
        end
        tmp_data2 = cell2table(Table);
        writetable(tmp_data2,temp_path,'WriteVariableNames',0);         
        [groups_data] = read_trajectory_groups(temp_path);        
        % close current figure and continue executing
        try 
            close(gcf); 
        catch
            warning('Window already closed');
        end        
    end
    function cancel_callback(varargin)     
        % close current figure and continue executing
        temp_path = varargin{3};
        try  
            delete(temp_path)
            warning('off','all')
            close(gcf); 
            warning('off','all')
        catch
            warning('Temp file not deleted.');
            warning('Window already closed');
            close(gcf); 
        end        
    end
end

