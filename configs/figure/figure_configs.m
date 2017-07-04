%% GUI for setting up the figures options and export format

function varargout = figure_configs(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figure_configs_OpeningFcn, ...
                   'gui_OutputFcn',  @figure_configs_OutputFcn, ...
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

% --- Executes just before figure_configs is made visible.
function figure_configs_OpeningFcn(hObject, eventdata, handles, varargin)
    % read configs.txt
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % fonts
    fonts = listfonts;
    for i=1:length(fonts)
        if isequal(fonts{i,1},FontName)
            idx = i;
            break;
        end    
    end    
    set(handles.fname,'String',fonts);
    set(handles.fname,'Value',idx);
    % sizes
    sizes = {};
    for i=1:30
        sizes=[sizes,i];
        if isequal(sizes{1,i},FontSize)
            idx = i;
        end    
    end
    set(handles.fsize,'String',sizes);
    set(handles.fsize,'Value',idx);
    % sample
    idx1 = get(handles.fname,'Value');
    idx2 = get(handles.fsize,'Value');
    a = get(handles.fname,'String');
    b = get(handles.fsize,'String');
    set(handles.sample,'FontName',a{idx1,1});
    set(handles.sample,'FontSize',str2num(b{idx2,1}));
    % widths
    widths = {};
    for i=0.5:0.5:5
        widths=[widths,i];
    end
    for i=1:length(widths)
        if isequal(widths{1,i},LineWidth)
            idx = i;
        end
    end    
    set(handles.lwidth,'String',widths);
    set(handles.lwidth,'Value',idx);
    plot([0 1],[0 0],'r-','LineWidth',widths{1,idx});
    axis off;
    % formats
    formats = {'MATLAB FIG-file (.fig)',...
               'JPEG image (.jpg)',...
               'Portable Network Graphics (.png)',...
               'Encapsulated PostScript (.eps)',...
               'Scalable Vector Graphics (.svg)',...
               'Portable Document Format (.pdf)',...
               'Windows bitmap (.bmp)',...
               'TIFF image, compressed (.tif)'};
    set(handles.export,'String',formats);
    for i=1:length(formats)
        a = formats{1,i};
        split = strfind(a,'.');
        a = a(split:end-1);
        if isequal(a,Export)
            idx = i;
            break;
        end   
    end    
    set(handles.export,'Value',idx); 
    %extra
    special = {'Low Quality','High Quality'};
    for i=1:length(formats)
        if isequal(special{1,i},ExportStyle)
            idx = i;
            break;
        end   
    end    
    set(handles.export_style,'String',special);
    set(handles.export_style,'Value',idx); 
    % Choose default command line output for browse
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes browse wait for user response (see UIRESUME)
    uiwait(handles.figure_configs);
% --- Outputs from this function are returned to the command line.
function varargout = figure_configs_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.figure_configs);
function figure_configs_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.figure_configs, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, use UIRESUME
        uiresume(handles.figure_configs);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.figure_configs);
    end

function fname_Callback(hObject, eventdata, handles)
    % sample
    idx1 = get(handles.fname,'Value');
    idx2 = get(handles.fsize,'Value');
    a = get(handles.fname,'String');
    b = get(handles.fsize,'String');
    set(handles.sample,'FontName',a{idx1,1});
    set(handles.sample,'FontSize',str2num(b{idx2,1}));
function fname_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function fsize_Callback(hObject, eventdata, handles)
    % sample
    idx1 = get(handles.fname,'Value');
    idx2 = get(handles.fsize,'Value');
    a = get(handles.fname,'String');
    b = get(handles.fsize,'String');
    set(handles.sample,'FontName',a{idx1,1});
    set(handles.sample,'FontSize',str2num(b{idx2,1}));
function fsize_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function lwidth_Callback(hObject, eventdata, handles)
    cla
    idx1 = get(handles.lwidth,'Value');
    a = get(handles.lwidth,'String');
    plot([0 1],[0 0],'r-','LineWidth',str2num(a{idx1,1}));
    axis off;
function lwidth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function export_Callback(hObject, eventdata, handles)
function export_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
function export_style_Callback(hObject, eventdata, handles)
function export_style_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function ok_Callback(hObject, eventdata, handles)
    % get the new configs
    contents = gui_configs_get_data(handles);
    % save them
    save_configs(cell2table(contents));
    % close
    figure_configs_CloseRequestFcn(hObject, eventdata, handles)
          
function cancel_Callback(hObject, eventdata, handles)
    figure_configs_CloseRequestFcn(hObject, eventdata, handles)
    
function axes1_CreateFcn(hObject, eventdata, handles)
    axis off;

function default_Callback(hObject, eventdata, handles)
    % read the default configs
    contents = read_defaults;
    % save them
    save_configs(cell2table(contents));
    % Update the gui
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;  
    fonts = get(handles.fname,'String');
    for i=1:length(fonts);
        if isequal(fonts{i,1},FontName)
            idx = i;
            break;
        end    
    end    
    set(handles.fname,'Value',idx);
    sizes = get(handles.fsize,'String');
    for i=1:length(sizes)
        if isequal(str2num(sizes{i,1}),FontSize)
            idx = i;
        end    
    end
    set(handles.fsize,'Value',idx);
    idx1 = get(handles.fname,'Value');
    idx2 = get(handles.fsize,'Value');
    a = get(handles.fname,'String');
    b = get(handles.fsize,'String');
    set(handles.sample,'FontName',a{idx1,1});
    set(handles.sample,'FontSize',str2num(b{idx2,1}));
    % widths
    widths = get(handles.lwidth,'String');
    for i=1:length(widths)
        if isequal(str2num(widths{i,1}),LineWidth)
            idx = i;
        end
    end    
    set(handles.lwidth,'Value',idx);
    plot([0 1],[0 0],'r-','LineWidth',str2num(widths{idx,1}));
    axis off;
    % formats
    formats = get(handles.export,'String');
    for i=1:length(formats)
        a = formats{i,1};
        split = strfind(a,'.');
        a = a(split:end-1);
        if isequal(a,Export)
            idx = i;
            break;
        end   
    end    
    set(handles.export,'Value',idx); 
    %extra
    special = get(handles.export_style,'String');
    for i=1:length(formats)
        if isequal(special{i,1},ExportStyle)
            idx = i;
            break;
        end   
    end    
    set(handles.export_style,'Value',idx);

