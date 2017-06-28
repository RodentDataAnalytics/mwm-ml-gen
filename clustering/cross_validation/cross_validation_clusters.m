function [s,e,step,other] = cross_validation_clusters(varargin)
%CROSS_VALIDATION_CLUSTERS

    s = -1;
    e = -1;
    step = -1;
    other = -1;
        
    % General GUI Settings
    units = 'points';
    resizable = 'off';
    fontname = 'Arial';
    fontsize = 11;
    fontunits = 'points';
    
    name = 'K-fold Cross Validation';

    %% Create Figure
    h.f = figure('units',units,'position',[100,130,260,80],...
         'toolbar','none','menu','none','resize',resizable,...
         'name',name,'NumberTitle','off');
    
    %% Create Min - Max
    % Labels
    h.label_min = uicontrol('style','text','units',units,...
                 'position',[10,61,70,15],'string',{'Min Clusters'},...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'HorizontalAlignment','left');
    h.label_max = uicontrol('style','text','units',units,...
                 'position',[100,61,70,15],'string',{'Max Clusters'},...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'HorizontalAlignment','left');  
    h.label_step = uicontrol('style','text','units',units,...
                 'position',[190,61,70,15],'string',{'Step'},...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'HorizontalAlignment','left');   
             
    % Min number of clusters         
    h.text_min = uicontrol('style','edit','units',units,...
                 'position',[10,41,40,18],'string','10',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'enable','off');  
    h.min_up = uicontrol('style','pushbutton','units',units,...
             'position',[50,49,20,10],'string','<html>&#x25B2;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@up_callback,h,1});            
    h.min_down = uicontrol('style','pushbutton','units',units,...
             'position',[50,40,20,10],'string','<html>&#x25BC;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@down_callback,h,1}); 
         
    % Max number of clusters         
    h.text_max = uicontrol('style','edit','units',units,...
                 'position',[100,41,40,18],'string','100',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'enable','off'); 
    h.max_up = uicontrol('style','pushbutton','units',units,...
             'position',[140,49,20,10],'string','<html>&#x25B2;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@up_callback,h,2});            
    h.max_down = uicontrol('style','pushbutton','units',units,...
             'position',[140,40,20,10],'string','<html>&#x25BC;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@down_callback,h,2});              
             
    % Step         
    h.text_step = uicontrol('style','edit','units',units,...
                 'position',[190,41,40,18],'string','10',...
                 'fontname',fontname,'fontsize',fontsize,...
                 'fontunits',fontunits,'enable','off','fontweight','bold');          
    h.step_up = uicontrol('style','pushbutton','units',units,...
             'position',[230,49,20,10],'string','<html>&#x25B2;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@up_callback,h,3});            
    h.step_down = uicontrol('style','pushbutton','units',units,...
             'position',[230,40,20,10],'string','<html>&#x25BC;</html>',...
             'fontname',fontname,'fontsize',5,...
             'fontunits',fontunits,'callback',{@down_callback,h,3});  
         
    %% Create Popup Menu   
    h.pop = uicontrol('style','popup','units',units,...
             'String', {'labels'},...
             'position',[10,15,60,18],...
             'fontname',fontname,'fontsize',fontsize,...
             'fontunits',fontunits);      
    
    %% Create Exit
    h.ok = uicontrol('style','pushbutton','units',units,...
                'position',[140,10,45,20],'string','OK',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,...
                'callback',{@ok_callback,h}); 
    h.cancel = uicontrol('style','pushbutton','units',units,...
                'position',[185,10,45,20],'string','Cancel',...
                'fontname',fontname,'fontsize',fontsize,...
                'fontunits',fontunits,'callback',{@cancel_callback});   
            
    inc_dec = str2num(get(h.text_step,'string'));
    
    %% Lock the figure
    lock = gcf;
    uiwait(lock);
    
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
                if step == 1
                    step = 5;
                else    
                    step = step + 5;
                end    
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
                if step == 5
                    step = 1;
                    set(h.text_step,'string',step);   
                    inc_dec = step;
                elseif step - 5 < 5
                    return;
                else
                    step = step - 5;
                    set(h.text_step,'string',step);   
                    inc_dec = step;
                end    
        end
    end       

    function ok_callback(varargin) 
        s = str2num(get(h.text_min,'string'));
        e = str2num(get(h.text_max,'string'));
        step = str2num(get(h.text_step,'string'));
        idx = get(h.pop,'Value');
        other = get(h.pop,'string');
        other = other{idx};
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

