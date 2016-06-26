function [ num_of_clusters ] = number_of_clusters(segmentation_configs, labels_path)
%NUMBER_OF_CLUSTERS indicates the ideal number of predefined clusters

    % General GUI Settings
    units = 'points';
    resizable = 'off';
    fontname = 'Arial';
    fontsize = 11;
    fontunits = 'points';
    font_name = '<font family=Arial>';
    font_size = '<font size=4>';
    
    name = 'Number of Clusters';
    num_of_clusters = 0;

    %% Create Figure
    h.f = figure('units',units,'position',[100,150,440,180],...
         'toolbar','none','menu','none','resize',resizable,...
         'name',name,'NumberTitle','off');
    
    %% Create Table
    % column names
    str1 = ['<html>' font_name font_size 'Proposed</html>'];
    str2 = ['<html>' font_name font_size 'Errors(%)</html>'];
    str3 = ['<html>' font_name font_size 'Undefined(%)</html>'];
    str4 = ['<html>' font_name font_size 'Coverage(%)</html>'];
    str5 = ['<html>' font_name font_size 'Check</html>']; 
    %ColumnName = {'Proposed','Errors(%)','Undefined(%)','Coverage(%)','Check'};
    ColumnName = {str1,str2,str3,str4,str5};
    % column width
    col_w = {73,75,88,85,45};    
    % column format
    ColumnFormat = {'short','short','short','short','logical'};
    ColumnEditable =  [false false false false true]; 
    % create the table
    t = uitable('units',units,'Position',[150,10,278,160],'columnwidth',col_w,...
                'ColumnFormat',ColumnFormat,'ColumnEditable',ColumnEditable,...
                'fontname',fontname,'fontsize',fontsize,'fontunits',fontunits,...
                'ColumnName',ColumnName,'RowName',[],'CellEditCallback',@checkboxes);     

    %% Create Min - Max
    % Labels
    h.label_min = uicontrol('style','text','units',units,...
                 'position',[10,151,70,15],'string',{'Min Clusters'},...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);
    h.label_max = uicontrol('style','text','units',units,...
                 'position',[10,131,70,15],'string',{'Max Clusters'},...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);  
    h.label_step = uicontrol('style','text','units',units,...
                 'position',[10,111,70,15],'string',{'Step'},...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits);   
             
    % Texts         
    h.text_min = uicontrol('style','edit','units',units,...
                 'position',[85,151,40,18],'string','10',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'enable','off');        
    h.text_max = uicontrol('style','edit','units',units,...
                 'position',[85,131,40,18],'string','100',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'enable','off'); 
    h.text_step = uicontrol('style','edit','units',units,...
                 'position',[85,111,40,18],'string','10',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'enable','off','fontweight','bold');          
             
    % min up/down         
    h.min_up = uicontrol('style','pushbutton','units',units,...
             'position',[125,160,20,10],'string','<html>&#x25B2;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@up_callback,h,1});            
    h.min_down = uicontrol('style','pushbutton','units',units,...
             'position',[125,151,20,10],'string','<html>&#x25BC;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@down_callback,h,1}); 
    % max up/down     
    h.max_up = uicontrol('style','pushbutton','units',units,...
             'position',[125,139,20,10],'string','<html>&#x25B2;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@up_callback,h,2});            
    h.max_down = uicontrol('style','pushbutton','units',units,...
             'position',[125,130,20,10],'string','<html>&#x25BC;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@down_callback,h,2});       
    % step up/down     
    h.step_up = uicontrol('style','pushbutton','units',units,...
             'position',[125,119,20,10],'string','<html>&#x25B2;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@up_callback,h,3});            
    h.step_down = uicontrol('style','pushbutton','units',units,...
             'position',[125,110,20,10],'string','<html>&#x25BC;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@down_callback,h,3});         
         
    %% Run - Graphs
    h.run = uicontrol('style','pushbutton','units',units,...
                'position',[40,70,90,25],'string','Run',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,...
                'callback',{@run_callback,h});     
    h.graphs = uicontrol('style','pushbutton','units',units,...
                'position',[40,40,90,25],'string','Show Graphs',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,...
                'callback',{@graphs_callback,h});     
    
    %% Create Exit
    h.ok = uicontrol('style','pushbutton','units',units,...
                'position',[40,10,45,20],'string','OK',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,...
                'callback',{@ok_callback,h}); 
    h.cancel = uicontrol('style','pushbutton','units',units,...
                'position',[85,10,45,20],'string','Cancel',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@cancel_callback});   
            
    inc_dec = str2num(get(h.text_step,'string'));
    
    %% Lock the figure
    lock = gcf;
    uiwait(lock);
    
    %% Cell Edit Callback Function
    % Ensures that only one checkbox at a time is checked
    function checkboxes(obj,event)
        table = get(obj,'Data');
        row = event.Indices(1);
        col = event.Indices(2);
        a = table{row,col};
        if table{row,col} == true
            for i = 1:size(table,1)
                if table{i,5} == true
                    table{i,5} = false;
                end  
            end 
        end   
        table{row,col} = a;
        set(obj,'Data',table);
    end    
    
    %% Callback Functions
    function up_callback(varargin) 
        option = varargin{4};
        try
            num_min = str2num(get(h.text_min,'string'));
            num_max = str2num(get(h.text_max,'string'));
            step = str2num(get(h.text_step,'string'));
        catch
            errordlg('Minimum and maximum number of clusters need to be numerics');
            return
        end    
        switch option
            case 1 % min clusters
                if num_min + inc_dec >= num_max;
                    return;
                else    
                    num_min = num_min + inc_dec;
                    set(h.text_min,'string',num_min);
                end    
            case 2 % max clusters
                num_max = num_max + inc_dec;
                set(h.text_max,'string',num_max);
            case 3 % step   
                step = step + 5;
                set(h.text_step,'string',step);
                inc_dec = step;
        end  
    end    

    function down_callback(varargin)
        option = varargin{4};
        try
            num_min = str2num(get(h.text_min,'string'));
            num_max = str2num(get(h.text_max,'string'));
            step = str2num(get(h.text_step,'string'));
        catch
            errordlg('Minimum and maximum number of clusters need to be numerics');
            return
        end    
        switch option
            case 1 % min clusters
                if num_min - inc_dec < 10;
                    return;
                else    
                    num_min = num_min - inc_dec;
                    set(h.text_min,'string',num_min);
                end    
            case 2 % max clusters
                if num_max - inc_dec <= num_min;
                    return;
                else    
                    num_max = num_max - inc_dec;
                    set(h.text_max,'string',num_max);
                end    
            case 3 % step 
                if step - 5 < 5
                    return;
                else
                    step = step - 5;
                    set(h.text_step,'string',step);   
                    inc_dec = step;
                end    
        end
    end   


    function run_callback(varargin)
        % get min/max
        min_num  = str2num(get(h.text_min,'string'));
        max_num  = str2num(get(h.text_max,'string'));
        step = str2num(get(h.text_step,'string'));
        % run clustering
        [nc,res1bare,res2bare,res1,res2,res3,covering]  = results_clustering_parameters(segmentation_configs,labels_path,min_num,max_num,inc_dec);
        [nc,per_errors1,per_undefined1,coverage] = algorithm_statistics(1,nc,res1bare,res2bare,res1,res2,res3,covering);                         
        % UPDATE THE TABLE
        data_old = get(t,'Data');
        a = false(1,length(nc));
        a = num2cell(a');
        data = [round(nc)', round(per_errors1)', round(per_undefined1)', round(coverage)'];
        data = num2cell(data);
        data = [data a]; 
        data_new = data;
        % first check if we already have some data...
        for i = 1:size(data_old,1)
            for j = 1:size(data,1)
                if isequal(data(j,1),data_old(i,1))
                    % ...if we do mark the data we already have...
                    data_old(i,:) = data(j,:);
                    data_new{j,1} = 0;
                end
            end
        end    
        %...remove the marked data
        a = size(data,1);
        for i = a:-1:1
            if data_new{i,1} == 0
                data_new(1,:) = [];
                %a = a-1;
            end
        end    
        % update the table
        data = [data_old ; data_new];      
        set(t,'Data',data);    
    end    

    function graphs_callback(varargin)
        tdata = get(t,'data');
        if isempty(tdata)
            return;
        end  
        % get min/max
        min_num  = str2num(get(h.text_min,'string'));
        max_num  = str2num(get(h.text_max,'string'));  
        step = str2num(get(h.text_step,'string'));
        try
            results_clustering_parameters(segmentation_configs,labels_path,min_num,max_num,inc_dec,1);
            return
        catch
            errordlg('Graphs cannot be generated.','Error');
            return
        end    
    end  


    function ok_callback(varargin) 
        tdata = get(t,'data');
        if isempty(tdata)
            return;
        end  
        for i = 1:size(tdata,1)
            if tdata{i,5}
                num_of_clusters = tdata{i,1};
                break;
            end
        end 
        if num_of_clusters == 0
            return;
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

