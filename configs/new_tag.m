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
items = {'Solid','Dashed','Dotted'};
set(handles.popup,'String',items);
set(handles.popup,'Value',1);
%if edit
if ~isempty(varargin)
    data = varargin{1,1};
    set(handles.ab,'String',data{1,1});
    set(handles.de,'String',data{1,2});
    set(handles.w,'String',data{1,4});
    set(handles.color,'BackgroundColor',data{1,5});
    for i = 1:length(items)
        if isequal(items{1,i},data{1,6})
            set(handles.popup,'Value',i);
            break;
        end
    end 
    %keep the txt line
    set(handles.ab,'UserData',varargin{1,2});
end    
% Choose default command line output for new_tag
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = new_tag_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;
lock = gcf;
uiwait(lock);

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
    data = parse_tags;
    ABBREVIATION = get(handles.ab,'String');
    DESCRIPTION = get(handles.de,'String');
    WEIGHT = get(handles.w,'String');
    COLOR = get(handles.color,'BackgroundColor');
    switch get(handles.popup,'Value') 
    case 1
        LINESTYLE = 'Solid';
    case 2
        LINESTYLE = 'Dashed';
    case 3    
        LINESTYLE = 'Dotted';
    end
    %check user input
    correct = check_tags(ABBREVIATION,DESCRIPTION,WEIGHT,data,get(handles.ab,'UserData'));
    if ~correct
        return;
    end    
    %Generate ID
    if isempty(get(handles.ab,'UserData'))
        ID = data{end,3}+1;
        new = {ABBREVIATION,DESCRIPTION,ID,str2num(WEIGHT),COLOR,LINESTYLE};
        data = [data;new];
    else
        pointer = get(handles.ab,'UserData');
        ID = data{pointer,3};
        new = {ABBREVIATION,DESCRIPTION,ID,str2num(WEIGHT),COLOR,LINESTYLE};
        for i = 1:size(new,2)
            data{pointer,i} = new{1,i};
        end    
    end    
    %Write to file
    write_tags_to_file(data);
    close(gcf);
    
function cancel_Callback(hObject, eventdata, handles)
    close(gcf);
    
function popup_Callback(hObject, eventdata, handles)
function popup_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
