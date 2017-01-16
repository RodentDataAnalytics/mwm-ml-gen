function varargout = new_project(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_project_OpeningFcn, ...
                   'gui_OutputFcn',  @new_project_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before new_project is made visible.
function new_project_OpeningFcn(hObject, eventdata, handles, varargin) 
    set(handles.new_project,'UserData',varargin{1});
    set(handles.table,'Data',{});
    sortby = {'Name','Session','ID','Group','Points','Available'};
    set(handles.sort_by,'String',sortby);
    set(handles.table,'ColumnEditable',[false,false,false,false,false,false,false]);
    %0 = data format, 1 = raw data, 2 = groups
    set(handles.table,'UserData',{0,1,2});
    %disable properties_panel and plotter_panel
    set(findall(handles.properties_panel, '-property', 'enable'), 'enable', 'off');
    set(findall(handles.plotter_panel, '-property', 'enable'), 'enable', 'off');
    %disable Assign and Refresh buttons
    set(handles.assign_groups,'Enable','off');
    set(handles.refresh_table,'Enable','off')
    %disable properties fields
    set(handles.f_days,'Enable','off');
    set(handles.f_trials,'Enable','off');
    %disable sorting the table
    set(handles.sort_by,'Enable','off');
    set(handles.descend,'Enable','off');
    set(handles.exclude_group,'Enable','off');
% Choose default command line output for new_project
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes new_project wait for user response (see UIRESUME)
uiwait(handles.new_project);
% --- Outputs from this function are returned to the command line.
function varargout = new_project_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.new_project);
function new_project_CloseRequestFcn(hObject, eventdata, handles)
%code from http://blogs.mathworks.com/videos/2010/02/12/advanced-getting-an-output-from-a-guide-gui/
    if isequal(get(handles.new_project, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        cla
        uiresume(handles.new_project);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.new_project);
    end
    
% FINALIZE and EXIT
function finalize_Callback(hObject, eventdata, handles)
    tmp = get(handles.table,'UserData');
    %get the animal groups
    trajectory_groups = tmp{3};
    %get the properties
    properties = get_properties(handles); 
    %get days and trials
    days = str2num(get(handles.f_days,'String'));
    trials = str2num(get(handles.f_trials,'String'));
    if isempty(tmp) || isempty(trajectory_groups) || isempty(properties) || isempty(days) || isempty(trials)
        errordlg('All fields of data format, settings and properties must be filled','Error');
        return
    end
    %generate properies
    new_properties = fix_properties(properties,days,trials);
    %important: we need to take the data by their loading order
    data = get(handles.table,'Data');
    original_table = get(handles.sort_by,'UserData');
    for i = 1:size(data,1)
        availability = data{i,7};
        if availability
            for j = 1:size(original_table,1)
                if isequal(data{i,1},original_table{j,1}) && data{i,2} == original_table{j,2} && data{i,3} == original_table{j,3}
                    original_table{j,4} = data{i,4};
                    original_table{j,7} = 1;
                end
            end
        end
    end    
    %check the availability and if it is 1 take this file
    my_trajectories = trajectories([]);
    k = 1;
    for i = 1:size(original_table,1)
        availability = original_table{i,7};
        group = original_table{i,4};
        if availability
            %centralize the trajectory to point 0,0 and chop end points
            original_table{i,5} = centralize_trajectory(properties,original_table{i,5},'chop');
            %create trajectory object and push it to the object pool
            my_trajectories = append_trajectory(my_trajectories,i,k,group,original_table);
            k = k+1;
        end
    end    
    %fix days and trials
    [my_trajectories,error] = fix_traj_info(trials,days,my_trajectories);
    if error %assert
        errordlg('All the trajectories were excluded','Fix trajectories info');
        return;
    end    
    %save everything
    m_path = get(handles.new_project,'UserData');
    m_path = char_project_path(m_path);
    save(fullfile(m_path,'settings','animal_groups.mat'),'trajectory_groups');
    save(fullfile(m_path,'settings','new_properties.mat'),'new_properties');
    save(fullfile(m_path,'settings','my_trajectories.mat'),'my_trajectories');
    new_project_CloseRequestFcn(hObject, eventdata, handles)

% PLOTTER
function axes1_CreateFcn(hObject, eventdata, handles)
    axis off;
function ok_Callback(hObject, eventdata, handles) 
    plotter_navigation(hObject,handles,eventdata);
function previous_Callback(hObject, eventdata, handles)
    plotter_navigation(hObject,handles,eventdata);
function next_Callback(hObject, eventdata, handles)
    plotter_navigation(hObject,handles,eventdata);
function navigator_Callback(hObject, eventdata, handles)
function navigator_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% PLOTTER OPTIONS
function view_arena_Callback(hObject, eventdata, handles)
    check_and_draw_arena(eventdata,handles);                 
function view_trajectory_Callback(hObject, eventdata, handles)
    raw_data = get(handles.table,'UserData');
    raw_data = raw_data{2};
    idx = str2num(get(handles.navigator,'String'));
    if isempty(idx)
    	return
    end    
    data = get(handles.table,'Data');
    if idx > size(data,1) || idx <= 0
        return
    end
    if data{idx,7} == 0
        return
    end    
    ses = data{idx,2};
    name = data{idx,1};
    for i = 1:size(raw_data,1)
        if isequal(raw_data{i,ses}{1},name)
            points = raw_data{i,ses}{4};
            check_and_draw_trajectory(eventdata,handles,points);
            return;
        end
    end        
function view_both_Callback(hObject, eventdata, handles)
    raw_data = get(handles.table,'UserData');
    raw_data = raw_data{2};
    idx = str2num(get(handles.navigator,'String'));
    if isempty(idx)
    	return
    end    
    data = get(handles.table,'Data');
    if idx > size(data,1) || idx <= 0
        return
    end
    if data{idx,7} == 0
        return
    end    
    ses = data{idx,2};
    name = data{idx,1};
    for i = 1:size(raw_data,1)
        if isequal(raw_data{i,ses}{1},name)
            points = raw_data{i,ses}{4};
            check_and_draw_arena(eventdata,handles)
            check_and_draw_trajectory(eventdata,handles,points);
            return;
        end
    end     

% DATA FORMAT & PROPERTIES BUTTONS
function path_select_Callback(hObject, eventdata, handles)
    FN_data = uigetdir(matlabroot,'Select data folder');
    if isnumeric(FN_data)
       return
    end       
    set(handles.path_data,'String',FN_data);    
function load_data_button_Callback(hObject, eventdata, handles)
    format = {get(handles.path_data,'String'),...
              get(handles.f_id,'String'),...
              get(handles.f_time,'String'),...
              get(handles.f_x,'String'),...
              get(handles.f_y,'String')}; 
    %check the format      
    [error] = check_format(format);
    if error
        errordlg('Format fields. Data dir, ID, Rec Time, X and Y fields cannot be empty.','Input Error');
        return;
    end    
    %if user reloads data
    set(handles.refresh_table,'Enable','off')
    set(handles.f_days,'Enable','off');
    set(handles.f_trials,'Enable','off');
    set(handles.sort_by,'Enable','off');
    set(handles.descend,'Enable','off');
    set(handles.table,'ColumnEditable',[false,false,false,false,false,false,false]);
    set(handles.exclude_group,'Enable','off');
    %load the data
    [data, table_data, session] = load_files(format{1}, format{2}, format{3}, format{4}, format{5});
    if isempty(data) || isempty(table_data)
        errordlg('No data found on the specified directory.','Input Error');
        return
    end    
    try
        if isempty(table_data{1,1})
            errordlg('No data found on the specified directory.','Input Error');
            return  
        end
    catch
            errordlg('No data found on the specified directory.','Input Error');
            return  
    end
    set(handles.f_sessions,'String',session);
    %update the table
    available = cell(size(table_data,1),1);
    col = cell(size(table_data,1),1);
    for i = 1:length(available)
        available{i} = 0;
        col{i} = false;
    end    
    table_data = [table_data,col,available];
    set(handles.table,'Data',table_data);
    tmp = get(handles.table,'UserData');
    %update UserData
    set(handles.table,'UserData',{format,data,tmp{3}});
    %keep the original table
    original_table = get(handles.table,'Data');
    %transfer all data to 1 column
    data_ = cell(size(original_table,1),1);
    k = 1;
    for i = 1:session
        for j = 1:size(data,1)
            if isempty(data{j,i})
                break;
            end    
            data_{k} = data{j,i};
            k = k+1;
            if k > size(data_,1)
                break;
            end
        end
    end    
    %'UserData' of sort_by will hold the original table with the pts       
    for i = 1:size(original_table,1)
        original_table{i,5} = data_{i}{4};
    end    
    set(handles.sort_by,'UserData',original_table);
    %update the GUI
    tmp = get(handles.table,'Data');
    if ~isempty(tmp)
        set(handles.assign_groups,'Enable','on');
        set(handles.sort_by,'Enable','on');
        set(handles.descend,'Enable','on');
        set(findall(handles.properties_panel, '-property', 'enable'), 'enable', 'on');
        set(findall(handles.properties_panel, '-property', 'enable'), 'enable', 'on');
    end       
function assign_groups_Callback(hObject, eventdata, handles)
    data = get(handles.table,'Data');
    m_path = get(handles.new_project,'UserData');
    m_path = char_project_path(m_path);
    %find the rows that do not have NaN as ID or Points
    sessions_ids = cell2mat(data(:,[2,3,5]));
    remain = find(~isnan(sessions_ids(:,2)) & ~isnan(sessions_ids(:,3)));
    sessions_ids = sessions_ids(remain,1:2);
    %hide this GUI
    [temp, idx] = hide_gui('New Project');
    %load the assign_groups GUI
    groups = assign_groups(sessions_ids, 1, m_path); 
    if isempty(groups{1})
        set(handles.refresh_table,'Enable','off');
        set(handles.f_days,'Enable','off');
        set(handles.f_trials,'Enable','off');
        set(handles.table,'ColumnEditable',[false,false,false,false,false,false,false]);
        set(temp(idx),'Visible','on'); 
        return;
    else
        for i = 1:length(groups)
            current_ids = find(sessions_ids(:,1) == i);
            %for each animal id
            for j = 1:length(groups{i})
                %of each session
                for z = 1:length(current_ids)
                    if data{current_ids(z),3} == groups{i}(j,1)
                        data{current_ids(z),4} = groups{i}(j,2);
                    end
                end
            end
        end   
    end
    %update the table
    [new_data] = availability(data,0);
    set(handles.table,'Data',new_data);
    %update the UserData
    tmp = get(handles.table,'UserData');
    set(handles.table,'UserData',{tmp{1},tmp{2},groups});
    %update the GUI
    set(handles.refresh_table,'Enable','on');
    set(handles.f_days,'Enable','on');
    set(handles.f_trials,'Enable','on');
    groups = num2cell(unique(cell2mat(new_data(:,4))));
    exclude = ['None',groups'];
    set(handles.exclude_group,'String',exclude);
    %resume this GUI's visibility
    set(temp(idx),'Visible','on');    
    set(findall(handles.plotter_panel, '-property', 'enable'), 'enable', 'on');
function refresh_table_Callback(hObject, eventdata, handles)
    settings = {str2double(get(handles.f_days,'String')),...
                str2num(get(handles.f_trials,'String'))};
    %check the settings        
    [error] = check_settings(settings);    
    if error
        errordlg('Settings fields. Day and Trials per Day fields cannot be empty or have a zero value. In addition, Trials per day needs to be specified per day separated with comma (,).','Input Error');
        return;
    end
    data = get(handles.table,'Data');
    trials = sum(str2num(get(handles.f_trials,'String')));
    [new_data] = availability(data,trials);
    %update the table
    set(handles.table,'Data',new_data);
    set(handles.table,'ColumnEditable',[false,false,false,false,false,true,false]);
    set(handles.exclude_group,'Enable','on');

% TABLE PROPERTIES
function table_CellEditCallback(hObject, eventdata, handles)
    %check the settings 
    settings = {str2double(get(handles.f_days,'String')),...
                str2num(get(handles.f_trials,'String'))};       
    [error] = check_settings(settings);    
    if error
        errordlg('Settings fields. Day and Trials per Day fields cannot be empty or have a zero value. In addition, Trials per day needs to be specified per day separated with comma (,).','Input Error');
        return;
    end
    %get the data cell array of the table
    data = get(hObject,'Data');
    %get the column formats
    cols = get(hObject,'ColumnFormat'); 
    %if the column of the edited cell is logical
    if strcmp(cols(eventdata.Indices(2)),'logical') 
        %if the checkbox was set to true
        if eventdata.EditData 
            %set the data value to true
            data{eventdata.Indices(1),eventdata.Indices(2)}=true; 
        %if the checkbox was set to false    
        else 
            % set the data value to false
            data{eventdata.Indices(1),eventdata.Indices(2)}=false;  
        end
    end
    %update the table
    trials = sum(str2num(get(handles.f_trials,'String')));
    [new_data] = availability(data,trials);
    set(hObject,'Data',new_data);    
function sort_by_Callback(hObject, eventdata, handles)
    data = get(handles.table,'Data');
    idx = get(handles.sort_by,'Value');
    command = get(handles.sort_by,'String');
    command = command{idx};
    order = get(handles.descend,'Value');
    if order
        txt = 'descend';
    else
        txt = 'ascend';
    end    
    switch command
        case 'Name'
            [~, index] = sort(data(:,1));
            data = data(index,:);            
        case 'Session'
            [~, index] = sort([data{:,2}],txt);
            data = data(index,:);
        case 'ID'
            [~, index] = sort([data{:,3}],txt);
            data = data(index,:);
        case 'Group'
            [~, index] = sort([data{:,4}],txt);
            data = data(index,:);
        case 'Points'    
            [~, index] = sort([data{:,5}],txt);
            data = data(index,:);
        case 'Available'
            [~, index] = sort([data{:,7}],txt);
            data = data(index,:);
    end
    %update the table
    set(handles.table,'Data',data);
function sort_by_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function exclude_group_Callback(hObject, eventdata, handles)
    data = get(handles.table,'Data');
    idx = get(handles.exclude_group,'Value');
    command = get(handles.exclude_group,'String');
    command = command{idx};
    if isequal(command,'None')
        for i = 1:size(data,1)
            data{i,6} = false;
            refresh_table_Callback(hObject, eventdata, handles);
        end
    else
        for i = 1:size(data,1)
            if isequal(num2str(data{i,4}),command)
                data{i,6} = true;
                data{i,7} = 0;
            end
        end
    end
    set(handles.table,'Data',data);
function exclude_group_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
      
% DATA FORMAT
function path_data_Callback(hObject, eventdata, handles)
function path_data_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_id_Callback(hObject, eventdata, handles)
function f_id_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_time_Callback(hObject, eventdata, handles)
function f_time_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_x_Callback(hObject, eventdata, handles)
function f_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_y_Callback(hObject, eventdata, handles)
function f_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_days_Callback(hObject, eventdata, handles)
function f_days_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_trials_Callback(hObject, eventdata, handles)
function f_trials_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function f_sessions_Callback(hObject, eventdata, handles)
function f_sessions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% PROPERTIES
function p_timeout_Callback(hObject, eventdata, handles)
function p_timeout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_centreX_Callback(hObject, eventdata, handles)
function p_centreX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_centreY_Callback(hObject, eventdata, handles)
function p_centreY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_arena_Callback(hObject, eventdata, handles)
function p_arena_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_platX_Callback(hObject, eventdata, handles)
function p_platX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_platY_Callback(hObject, eventdata, handles)
function p_platY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_platform_Callback(hObject, eventdata, handles)
function p_platform_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function p_flipX_Callback(hObject, eventdata, handles)
function p_flipY_Callback(hObject, eventdata, handles)

function descend_Callback(hObject, eventdata, handles)
