function varargout = gui_similarity(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_similarity_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_similarity_OutputFcn, ...
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


% --- Executes just before gui_similarity is made visible.
function gui_similarity_OpeningFcn(hObject, eventdata, handles, varargin)
    [tag_names,~] = browse_open_function;
    if tag_names{1} == 0 
        disp('Cannot load tags');
        return;
    end
    data = zeros(length(tag_names),3);
    set(handles.table1,'RowName',tag_names);
    set(handles.table1,'Data',data);
    if ~isempty(varargin)
        set(handles.gui_similarity,'UserData',varargin{1});  
    end 
    handles.output = hObject;
    guidata(hObject, handles);
    if ~isempty(varargin)
        uiwait(handles.gui_similarity);
    end
function varargout = gui_similarity_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    if ~isempty(get(handles.gui_similarity,'UserData'))
        delete(handles.gui_similarity);
    end
function close_fnc_Callback(hObject, eventdata, handles)
    gui_similarity_CloseRequestFcn(hObject, eventdata, handles)
function gui_similarity_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.gui_similarity, 'waitstatus'), 'waiting')
        uiresume(handles.gui_similarity);
    else
        delete(handles.gui_similarity);
    end

function pathstr = uiget(handles)
    project_path = get(handles.gui_similarity,'UserData');
    project_path = char_project_path(project_path);
    if isempty(project_path)
        project_path = matlabroot;
    end
    sel = get(handles.selection.SelectedObject,'String');
    switch sel
        case 'Folders'
            pathstr = uigetdir(project_path,'Select classification folder');
            if isnumeric(pathstr)
                return
            end   
            files = dir(fullfile(pathstr,'*.mat'));
            if isempty(files)
                errordlg('The selectedfolder contains no MAT files','Empty folder');
                return;
            end
        case 'Files'
            [namestr,pathstr] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select classification file',project_path);
            if isnumeric(namestr) || isnumeric(pathstr)
               return
            end     
            pathstr = strcat(pathstr,namestr);       
    end
    
function refresh_similarity_Callback(hObject, eventdata, handles)
    project_path = get(handles.gui_similarity,'UserData');
    project_path = char_project_path(project_path);
    f1 = get(handles.field1,'String');
    f2 = get(handles.field2,'String');     
    if isempty(f1) || isempty(f2) || isequal(f1,f2)
        errordlg('Two different classifications have to be specified.','Error');
        return
    end
    [class_1,class_2,diff] = test_similarity(project_path,f1,f2);
    if isempty(class_1)
        data = zeros(length(tag_names),3);
        set(handles.table1,'Data',data);
        return
    end
    data = [class_1',class_2',diff'];
    set(handles.table1,'Data',data);
    
function export_table_Callback(hObject, eventdata, handles)
    data = get(handles.table1,'Data');
    tags = get(handles.table1,'RowName');
    data = num2cell(data);
    data = [tags,data];
    data = cell2table(data,'VariableName',{'Table','Class1','Class2','Difference'});
    p1 = get(handles.field1,'String');
    p2 = get(handles.field2,'String');
    if isempty(data) || isempty(p1) || isempty(p2)
        return;
    end
    p1 = strsplit(p1,{'/','\'});
    if ~isempty(strfind(p1{end},'.mat'))
        p1 = p1{end}(1:end-4);
    else
        p1 = p1{end};
    end
    p2 = strsplit(p2,{'/','\'});
    if ~isempty(strfind(p2{end},'.mat'))
        p2 = p2{end}(1:end-4);
    else
        p2 = p2{end};
    end    
    results_path = get(handles.gui_similarity,'UserData');
    time = fix(clock);
    formatOut = 'yyyy-mm-dd-HH-MM';
    time = datestr((time),formatOut);
    if ~exist(fullfile(char(results_path{1}),'results','similarity'),'dir');
        mkdir(fullfile(char(results_path{1}),'results','similarity'));
    end
    results_path = fullfile(char(results_path{1}),'results','similarity',strcat(p1,'-',p2,'@',time,'.csv'));
    % create the file
    try
        fid = fopen(results_path,'w');
        fclose(fid);      
        %save to file
        writetable(data,results_path,'WriteVariableNames',1);
        msgbox('Export Completed');
    catch
        errordlg('Cannot create file for saving the data');
    end  
function set_f1_Callback(hObject, eventdata, handles)
    str = uiget(handles);
    if isequal(str,0)
        return
    end
    set(handles.field1,'String',str);
function set_f2_Callback(hObject, eventdata, handles)
    str = uiget(handles);
    if isequal(str,0)
        return
    end
    set(handles.field2,'String',str);
function field1_Callback(hObject, eventdata, handles)
function field1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function field2_Callback(hObject, eventdata, handles)
function field2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
