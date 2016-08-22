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
    %Initialize table
    contents = parse_tags;
    %Keep the primary file content
    set(handles.table1,'UserData',contents);
    %format color as: #FFFFFF and text same as color
    for i = 1:size(contents,1)
        contents{i,5} = dec2hex(round(contents{i,5}*255),2)'; contents{i,5} = ['#';contents{i,5}(:)]';
        contents{i,5} = strcat(['<html><body bgcolor="' contents{i,5} '" text="' contents{i,5} '" width="80px">'],contents{i,5});
    end
    %fill the table
    set(handles.table1,'data',contents(4:end,:));
    %Initialize pop-up
    count = size(get(handles.table1,'data'),1);
    items = {};
    for i = 1:count
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);
    % Choose default command line output for untitled
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % --- Outputs from this function are returned to the command line.

function varargout = tags_config_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    %% Lock the figure
    lock = gcf;
    uiwait(lock);

function selection_Callback(hObject, eventdata, handles)
function selection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_Callback(hObject, eventdata, handles)
    pointer = get(handles.selection,'Value')+3;
    data = parse_tags;
    temp = findobj('Type','figure');
    for i = 1:length(temp)
        name = get(temp(i),'Name');
        if isequal(name,'Configure Strategies')
            set(temp(i),'Visible','off'); 
            idx = i;
            break;
        end
    end     
    new_tag(data(pointer,:),pointer);
    set(temp(idx),'Visible','on');
    %Re-initialize table
    contents = parse_tags;
    %format color as: #FFFFFF and text same as color
    for i = 1:size(contents,1)
        contents{i,5} = dec2hex(round(contents{i,5}*255),2)'; contents{i,5} = ['#';contents{i,5}(:)]';
        contents{i,5} = strcat(['<html><body bgcolor="' contents{i,5} '" text="' contents{i,5} '" width="80px">'],contents{i,5});
    end
    %fill the table
    set(handles.table1,'data',contents(4:end,:));    
    
function remove_Callback(hObject, eventdata, handles)
    pointer = get(handles.selection,'Value')+3;
    data = parse_tags;
    for j=1:size(data,2)
        data{pointer,j} = {};
    end
    %remove empty rows (thanks to Ben van Oeveren)
    data(any(cellfun(@isempty,data),2),:) = [];
    %write to file
    write_tags_to_file(data);
    %Re-initialize table
    contents = parse_tags;
    %format color as: #FFFFFF and text same as color
    for i = 1:size(contents,1)
        contents{i,5} = dec2hex(round(contents{i,5}*255),2)'; contents{i,5} = ['#';contents{i,5}(:)]';
        contents{i,5} = strcat(['<html><body bgcolor="' contents{i,5} '" text="' contents{i,5} '" width="80px">'],contents{i,5});
    end
    %fill the table
    set(handles.table1,'data',contents(4:end,:));
    
function new_Callback(hObject, eventdata, handles)
    temp = findobj('Type','figure');
    for i = 1:length(temp)
        name = get(temp(i),'Name');
        if isequal(name,'Configure Strategies')
            set(temp(i),'Visible','off'); 
            idx = i;
            break;
        end
    end 
    run new_tag;
    set(temp(idx),'Visible','on');
    %Re-initialize table
    contents = parse_tags;
    %format color as: #FFFFFF and text same as color
    for i = 1:size(contents,1)
        contents{i,5} = dec2hex(round(contents{i,5}*255),2)'; contents{i,5} = ['#';contents{i,5}(:)]';
        contents{i,5} = strcat(['<html><body bgcolor="' contents{i,5} '" text="' contents{i,5} '" width="80px">'],contents{i,5});
    end
    %fill the table
    set(handles.table1,'data',contents(4:end,:));    
    
function default_Callback(hObject, eventdata, handles)
    contents = parse_tags(1); % read tags_default.txt;
    %Write to file
    write_tags_to_file(contents);
    %fill the table
    for i = 1:size(contents,1)
        contents{i,5} = dec2hex(round(contents{i,5}*255),2)'; contents{i,5} = ['#';contents{i,5}(:)]';
        contents{i,5} = strcat(['<html><body bgcolor="' contents{i,5} '" text="' contents{i,5} '" width="80px">'],contents{i,5});
    end
    set(handles.table1,'data',contents(4:end,:));  
    %fill pop-up
    count = size(get(handles.table1,'data'),1);
    items = {};
    for i = 1:count
        items = [items, num2str(i)];
    end
    set(handles.selection,'String',items);
    set(handles.selection,'Value',1);
    
function OK_Callback(hObject, eventdata, handles)
    temp = findobj('Type','figure');
    for i = 1:length(temp)
        name = get(temp(i),'Name');
        if isequal(name,'Configure Strategies')
            close(temp(i));
        elseif isequal(name,'New Strategy')   
            close(temp(i));
        end    
    end 
    %close(gcf);
    
function cancel_Callback(hObject, eventdata, handles)
    %reset
    primary = get(handles.table1,'UserData');  
    %Write to file
    write_tags_to_file(primary)
    %close
    temp = findobj('Type','figure');
    for i = 1:length(temp)
        name = get(temp(i),'Name');
        if isequal(name,'Configure Strategies')
            close(temp(i));
        elseif isequal(name,'New Strategy')   
            close(temp(i));
        end    
    end 
    %close(gcf);
