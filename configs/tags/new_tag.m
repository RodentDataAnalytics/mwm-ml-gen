%% GUI for setting up a new tag.
% It is generated from tags_config.m

function varargout = new_tag(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @new_tag_OpeningFcn, ...
                   'gui_OutputFcn',  @new_tag_OutputFcn, ...
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

% --- Executes just before new_tag is made visible.
function new_tag_OpeningFcn(hObject, eventdata, handles, varargin)
    set(handles.shortcut_pop, 'Visible', 'off'); %shortcuts
    set(handles.shortcut, 'Visible', 'off'); %shortcuts
    n = ('0':'9')';
    a = ('A':'Z')';
    items_al = [n;a];
    set(handles.shortcut_pop,'String',items_al);
    set(handles.shortcut_pop,'Value',1);
    pop_items = {'Solid','Dashed','Dotted'};
    set(handles.popup,'String',pop_items);
    set(handles.popup,'Value',1);
    av_items = {'public','trajectory','segment'};
    set(handles.tag_role,'String',av_items);
    set(handles.tag_role,'Value',1);
    set(handles.new_tag, 'UserData', varargin{1,1});
    set(handles.tag_role, 'UserData', 0);
    %if edit
    if length(varargin) > 1
        data = varargin{1,2};
        set(handles.ab,'String',data{1,1});
        set(handles.de,'String',data{1,2});
        idx1 = strfind(data{1,4},'[');
        idx2 = strfind(data{1,4},']');
        data{1,4} = str2num(data{1,4}(idx1:idx2));
        set(handles.color,'BackgroundColor',data{1,4});
        for i = 1:length(pop_items)
            if isequal(pop_items{1,i},data{1,5})
                set(handles.popup,'Value',i);
                break;
            end
        end 
        for i = 1:length(av_items)
            if isequal(av_items{1,i},data{1,6})
                set(handles.tag_role,'Value',i);
                break;
            end
        end
        set(handles.tag_role, 'UserData', str2num(data{1,3}));
    end    
    % Choose default command line output for browse
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes browse wait for user response (see UIRESUME)
    uiwait(handles.new_tag);
% --- Outputs from this function are returned to the command line.
function varargout = new_tag_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.new_tag);
function new_tag_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.new_tag, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.new_tag);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.new_tag);
    end

function ab_Callback(hObject, eventdata, handles)
function ab_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function de_Callback(hObject, eventdata, handles)
function de_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function id_Callback(hObject, eventdata, handles)
function id_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function w_Callback(hObject, eventdata, handles)
function w_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function line_Callback(hObject, eventdata, handles)
    
function line_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function color_Callback(hObject, eventdata, handles)
    col = uisetcolor;
    try
        set(handles.color,'BackgroundColor',col);
    catch
        return;
    end    
    
function ok_Callback(hObject, eventdata, handles)
    ppath = get(handles.new_tag, 'UserData');
    ppath = char_project_path(ppath);
    [~, data] = parse_tags(fullfile(ppath,'settings','tags.txt'));     
    data(1,:) = []; %remove title
    ABBREVIATION = get(handles.ab,'String');
    DESCRIPTION = get(handles.de,'String');
    COLOR = get(handles.color,'BackgroundColor');
    switch get(handles.popup,'Value') 
        case 1
            LINESTYLE = 'Solid';
        case 2
            LINESTYLE = 'Dashed';
        case 3    
            LINESTYLE = 'Dotted';
    end
    switch get(handles.tag_role,'Value') 
        case 1
            AVAIL = 'public';
        case 2
            AVAIL = 'trajectory';
        case 3    
            AVAIL = 'segments';
    end
    idx = get(handles.tag_role, 'UserData');
    %check user input
    correct = check_tags(ABBREVIATION,DESCRIPTION,data,idx);
    if ~correct
        return
    end    
    %Generate ID
    if idx == 0
        ID = str2num(data{end,3})+1;
        new = {ABBREVIATION,DESCRIPTION,ID,num2str(COLOR(1)),num2str(COLOR(2)),num2str(COLOR(3)),LINESTYLE,0,AVAIL};
        data = [data;new];
    else
        ID = data{idx,3};
        new = {ABBREVIATION,DESCRIPTION,ID,num2str(COLOR(1)),num2str(COLOR(2)),num2str(COLOR(3)),LINESTYLE,0,AVAIL};
        for i = 1:size(new,2)
            data{idx,i} = new{1,i};
        end    
    end    
    %Write to file
    write_tags_to_file(data,fullfile(ppath,'settings','tags.txt'));
    close(gcf);
    
function cancel_Callback(hObject, eventdata, handles)
    new_tag_CloseRequestFcn(hObject, eventdata, handles);
    
function popup_Callback(hObject, eventdata, handles)
function popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function shortcut_pop_Callback(hObject, eventdata, handles)
function shortcut_pop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function tag_role_Callback(hObject, eventdata, handles)
function tag_role_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
