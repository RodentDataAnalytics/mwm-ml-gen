function varargout = features_config(varargin)
% FEATURES_CONFIG MATLAB code for features_config.fig
%      FEATURES_CONFIG, by itself, creates a new FEATURES_CONFIG or raises the existing
%      singleton*.
%
%      H = FEATURES_CONFIG returns the handle to a new FEATURES_CONFIG or the handle to
%      the existing singleton*.
%
%      FEATURES_CONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FEATURES_CONFIG.M with the given input arguments.
%
%      FEATURES_CONFIG('Property','Value',...) creates a new FEATURES_CONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before features_config_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to features_config_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help features_config

% Last Modified by GUIDE v2.5 05-Jun-2017 14:50:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @features_config_OpeningFcn, ...
                   'gui_OutputFcn',  @features_config_OutputFcn, ...
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

%handles.feat_class,'UserData' = new features
%handles.feat_def,'UserData' = default features
%handles.load_seg,'UserData' = segmentation object

% --- Executes just before features_config is made visible.
function features_config_OpeningFcn(hObject, eventdata, handles, varargin)
%     features = features_list;
%     names = cell(1,length(features));
%     for i = 1:length(features)
%         names{i} = features{i}{2};
%     end
%     set(handles.feat_def,'String',names(:,9:11));
%     set(handles.feat_def,'Value',1);
%     set(handles.feat_class,'String',names(:,1:8));
%     set(handles.feat_class,'Value',1);  
    set(handles.feat_load,'Enable','off');
    set(handles.feat_def,'Enable','off');
    set(handles.feat_class,'Enable','off');
    set(handles.feat_transfer1,'Enable','off');
    set(handles.feat_transfer2,'Enable','off');
    set(handles.ok,'Enable','off');
    handles.output = hObject;
    guidata(hObject, handles);
% UIWAIT makes features_config wait for user response (see UIRESUME)
% uiwait(handles.features_config);
function varargout = features_config_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    
% LISTBOXES    
function feat_def_Callback(hObject, eventdata, handles)
function feat_def_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function feat_class_Callback(hObject, eventdata, handles)
function feat_class_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% TRANSFER
function feat_transfer1_Callback(hObject, eventdata, handles)
    set(handles.feat_transfer2,'Enable','on');
    %get the selected feature
    idx = get(handles.feat_def,'Value');
    sel = get(handles.feat_def,'String');
    sel = sel{idx};
    %move it to the other listbox
    names = get(handles.feat_class,'String');
    names{end+1} = sel;
    set(handles.feat_class,'String',names);    
    set(handles.feat_class,'Value',1); 
    %remove it from this one
    names = get(handles.feat_def,'String');
    names(idx) = [];
    if length(names) < 1
        names = '';
        set(handles.feat_transfer1,'Enable','off');
    end
    set(handles.feat_def,'String',names);
    set(handles.feat_def,'Value',1);
function feat_transfer2_Callback(hObject, eventdata, handles)
    set(handles.feat_transfer1,'Enable','on');
    %get the selected feature
    idx = get(handles.feat_class,'Value');
    sel = get(handles.feat_class,'String');
    sel = sel{idx};
    %move it to the other listbox
    names = get(handles.feat_def,'String');
    names{end+1} = sel;
    set(handles.feat_def,'String',names);    
    set(handles.feat_def,'Value',1); 
    %remove it from this one
    names = get(handles.feat_class,'String');
    names(idx) = [];
    if length(names) < 1
        names = '';
        set(handles.feat_transfer2,'Enable','off');
    end
    set(handles.feat_class,'String',names);
    set(handles.feat_class,'Value',1);

% LOAD
function feat_load_Callback(hObject, eventdata, handles)
    % remove any previous loaded features
    if ~isempty(get(handles.feat_class,'UserData'));
        names = get(handles.feat_class,'UserData');
        names = names(1,:);
        % remove from left listbox
        names1 = get(handles.feat_def,'String');
        rem = [];
        for i = 1:length(names1)
            for j = 1:length(names)
                if isequal(names1{i},names{j})
                    rem = [rem,i];
                end
            end
        end
        names1(rem) = [];
        % remove from right listbox
        names2 = get(handles.feat_class,'String');
        rem = [];
        for i = 1:length(names2)
            for j = 1:length(names)
                if isequal(names2{i},names{j})
                    rem = [rem,i];
                end
            end
        end
        names2(rem) = [];       
        if length(names1) < 1
            names = '';
            names = set(handles.feat_def,'String',names);
        end        
        if length(names2) < 1
            names = '';
            names = set(handles.feat_class,'String',names);
        end           
        set(handles.feat_def,'String',names1); 
        set(handles.feat_class,'String',names2); 
    end
    % load the new features
    [fname, pname] = uigetfile({'*.csv','CSV-file (*.csv)'},'Select CSV file containing computed features.');
    if pname == 0
        return;
    end    
    fpath = strcat(pname,fname);
    % open file and count the columns
    fid = fopen(fpath);
    header = fgetl(fid);
    num_cols = length(strsplit(header,','));
    % create a format specifier of the correct size
    fmt = repmat('%s ',[1,num_cols]);
    data = textscan(fid,fmt,'CollectOutput',1,'Delimiter',',');
    fclose(fid);
    data = data{1};
    header = strsplit(header,',');
    all_data = [header;data];
    set(handles.feat_class,'UserData',all_data);
    %UPDATE
    names = get(handles.feat_def,'String'); 
    for i = 1:length(names)
        if isequal(names,'');
            names(i) = [];
        end
    end
    names = [names;header'];
    set(handles.feat_transfer2,'Enable','on');
    if length(names) < 1
        names = '';
        set(handles.feat_transfer2,'Enable','off');
    end
    set(handles.feat_def,'String',names); 
    set(handles.feat_def,'Value',1); 
    
% TERMINATE
function ok_Callback(hObject, eventdata, handles)
    names = get(handles.feat_class,'String');
    if isequal(names{1},'');
        errordlg('At least one feature must be available for the classification procedure.','Error');
        return
    end
    a = get(handles.feat_def,'UserData');
    b = get(handles.feat_class,'UserData');
    matrix = [];
    for i = 1:length(names)
        for j = 1:size(a,2)
            if isequal(names{i},a{1,j})
                tmp = a(2:end,j);
                tmp = cell2mat(tmp);
                matrix = [matrix,tmp];
            end
        end
        for j = 1:size(b,2)
            if isequal(names{i},b{1,j})
                tmp = b(2:end,j);
                tmp = cellfun(@(x)str2double(x), tmp);
                matrix = [matrix,tmp];
            end
        end  
    end
    segmentation_configs = get(handles.load_seg,'UserData');
    feat = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,9:11);
    matrix = [matrix,feat];
    segmentation_configs.FEATURES_VALUES_SEGMENTS = matrix;
    str = get(handles.path_field,'String');
    [~,str,~] = fileparts(str);
    str = strcat(str,'-feat',num2str(size(matrix,2)-3));
    uisave('segmentation_configs',str);

% PATH
function load_seg_Callback(hObject, eventdata, handles)
    [fname, pname] = uigetfile({'*.mat','MATLAB-file (*.mat)'},'Select segmentation object.');
    if pname == 0
        return;
    end    
    fpath = strcat(pname,fname);
    try
        load(fpath)
    catch
        errordlg('Unable to load segmentation object.','Error');
    end
    fvalues = segmentation_configs.FEATURES_VALUES_SEGMENTS;
    fvalues = num2cell(fvalues);
    features = features_list;
    names = cell(1,length(features));
    for i = 1:length(features)
        names{i} = features{i}{2};
    end    
    features = [names;fvalues];
    set(handles.path_field,'String',fpath);
    set(handles.load_seg,'UserData',segmentation_configs);
    set(handles.feat_def,'UserData',features);
    set(handles.feat_def,'String',names(:,9:11));
    set(handles.feat_def,'Value',1);
    set(handles.feat_class,'String',names(:,1:8));
    set(handles.feat_class,'Value',1);       
    
    set(handles.feat_load,'Enable','on');
    set(handles.feat_def,'Enable','on');
    set(handles.feat_class,'Enable','on');
    set(handles.feat_transfer1,'Enable','on');
    set(handles.feat_transfer2,'Enable','on');
    set(handles.ok,'Enable','on');
function path_field_Callback(hObject, eventdata, handles)
function path_field_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
