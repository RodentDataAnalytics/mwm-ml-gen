%% GUI for setting up tags (strategies)

function varargout = tags_config(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tags_config_OpeningFcn, ...
                   'gui_OutputFcn',  @tags_config_OutputFcn, ...
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


% --- Executes just before untitled is made visible.
function tags_config_OpeningFcn(hObject, eventdata, handles, varargin)
    %Store the project folder
    set(handles.tags_config,'UserData',varargin{1});
    ppath = varargin{1};
    ppath = char_project_path(ppath);
    %Initialize table
    [~, contents] = parse_tags(fullfile(ppath,'settings','tags.txt'));
    %Keep the primary file content
    set(handles.table1,'UserData',contents);
    % Table size
    [~,s2] = size(get(handles.table1,'data'));
    %Create the table graphics and data
    data = produce_table(contents,s2);
    %Fill the table
    set(handles.table1,'data',data);
    %Initialize pop-up
    items = {};
    for i = 1:size(data,1)
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);
    %for the future...
    %ability to add/remove, save/load tags
    set(handles.remove,'Visible','off');
    set(handles.new,'Visible','off');
    set(handles.load,'Visible','off');
    set(handles.save,'Visible','off');    
    % Choose  command line output for browse
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes tags_config wait for user response (see UIRESUME)
    uiwait(handles.tags_config);
% --- Outputs from this function are returned to the command line.
function varargout = tags_config_OutputFcn(hObject, eventdata, handles) 
    % Get  command line output from handles structure
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.tags_config);
% --- Executes when user attempts to close tags_config.
function tags_config_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.tags_config, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.tags_config);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.tags_config);
    end

function selection_Callback(hObject, eventdata, handles)
function selection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('Configure Strategies');  
    ppath = get(handles.tags_config,'UserData');
    %ppath = char_project_path(ppath);
    pointer = get(handles.selection,'Value');
    data = get(handles.table1,'data');
    new_tag(ppath,data(pointer,:));
    set(temp(idx),'Visible','on');
    %Re-initialize table
    [~, contents] = parse_tags(fullfile(ppath,'settings','tags.txt'));
    set(handles.table1,'UserData',contents);
    % Table size
    [~,s2] = size(get(handles.table1,'data'));
    %Create the table graphics and data
    data = produce_table(contents,s2);
    %Fill the table
    set(handles.table1,'data',data); 
    
function remove_Callback(hObject, eventdata, handles)
    ppath = get(handles.tags_config,'UserData');
    ppath = char_project_path(ppath);
    pointer = get(handles.selection,'Value');
    [~, contents] = parse_tags(fullfile(ppath,'settings','tags.txt'));
    contents(pointer+1,:) = [];
    for i = 2:size(contents,1)
        contents{i,3} = i-1;
    end
    % Table size
    [~,s2] = size(get(handles.table1,'data'));
    %Create the table graphics and data
    data = produce_table(contents,s2);
    %Fill the table
    set(handles.table1,'data',data);     
    %Initialize pop-up
    count = size(get(handles.table1,'data'),1);
    items = {};
    for i = 1:count
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);   
    data = get(handles.table1,'data');
    c(data,fullfile(ppath,'settings','tags.txt'));
    
function new_Callback(hObject, eventdata, handles)
    [temp, idx] = hide_gui('Configure Strategies');  
    ppath = get(handles.tags_config,'UserData');
    ppath = char_project_path(ppath);
    new_tag(ppath);
    set(temp(idx),'Visible','on');
    %Re-initialize table
    [~, contents] = parse_tags(fullfile(ppath,'settings','tags.txt'));
    set(handles.table1,'UserData',contents);
    % Table size
    [~,s2] = size(get(handles.table1,'data'));
    %Create the table graphics and data
    data = produce_table(contents,s2);
    %Fill the table
    set(handles.table1,'data',data); 
    %Initialize pop-up
    count = size(get(handles.table1,'data'),1);
    items = {};
    for i = 1:count
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);   
    data = get(handles.table1,'data');
    write_tags_to_file(data,fullfile(ppath,'settings','tags.txt'));    
       
function default_Callback(hObject, eventdata, handles)
    ppath = get(handles.tags_config,'UserData');
    ppath = char_project_path(ppath);
    [~, contents] = parse_tags('tags_default'); % read tags_default.txt;
    % Table size
    [~,s2] = size(get(handles.table1,'data'));
    %Create the table graphics and data
    data = produce_table(contents,s2);
    %Fill the table
    set(handles.table1,'data',data);     
    %Initialize pop-up
    count = size(get(handles.table1,'data'),1);
    items = {};
    for i = 1:count
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);   
    %data = get(handles.table1,'data');
    write_tags_to_file(contents(4:end,:),fullfile(ppath,'settings','tags.txt'));
   
function OK_Callback(hObject, eventdata, handles)
    tags_config_CloseRequestFcn(hObject, eventdata, handles)
    
function cancel_Callback(hObject, eventdata, handles)
    ppath = get(handles.tags_config,'UserData');
    ppath = char_project_path(ppath);
    %reset
    primary = get(handles.table1,'UserData');  
    %Write to file
    write_tags_to_file(primary,ppath)
    %close
    tags_config_CloseRequestFcn(hObject, eventdata, handles)

function load_Callback(hObject, eventdata, handles)
    ppath = get(handles.tags_config,'UserData');
    ppath = char_project_path(ppath);
    [FileName,PathName] = uigetfile('*.txt','Select tags.txt');
    %Re-initialize table
    [~, contents] = parse_tags(fullfile(PathName,FileName));
    % Table size
    [~,s2] = size(get(handles.table1,'data'));
    %Create the table graphics and data
    data = produce_table(contents,s2);
    %Fill the table
    set(handles.table1,'data',data);     
    %Initialize pop-up
    count = size(get(handles.table1,'data'),1);
    items = {};
    for i = 1:count
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);   
    data = get(handles.table1,'data');
    write_tags_to_file(data,fullfile(ppath,'settings','tags.txt'));   


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
