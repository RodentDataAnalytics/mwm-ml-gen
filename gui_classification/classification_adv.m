function varargout = classification_adv(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @classification_adv_OpeningFcn, ...
                   'gui_OutputFcn',  @classification_adv_OutputFcn, ...
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

%%%% OPENING - VARARGOUT - CLOSING FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function classification_adv_OpeningFcn(hObject, eventdata, handles, varargin)
    set(handles.merge_rule,'String',{'Majority Voting'});
    set(handles.merge_rule,'Value',1);
    set(handles.rule_options,'UserData',0);
    [segmentations,labels,~] = pick_defaults(varargin{1});   
    set(handles.select_segmentation,'String',segmentations);
    set(handles.select_labels,'String',labels);
    set(handles.classification_adv,'UserData',varargin);
    set(handles.select_groups, 'Min', 0, 'Max', 5);
    set(handles.specified_classifiers,'UserData',0);
    refresh_classadv_Callback(hObject, eventdata, handles)
    if isequal(segmentations{1},'') || isequal(labels{1},'');
        errordlg('No segmentation or labelling data found','Error');
        classification_adv_CloseRequestFcn(hObject, eventdata, handles);
    end  
    handles.output = hObject;
    guidata(hObject, handles);
    uiwait(handles.classification_adv);
function varargout = classification_adv_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    if ~isempty(get(handles.classification_adv,'UserData'))
        delete(handles.classification_adv);
    end
function classification_adv_CloseRequestFcn(hObject, eventdata, handles)
    if isequal(get(handles.classification_adv, 'waitstatus'), 'waiting')
        uiresume(handles.classification_adv);
    else
        delete(handles.classification_adv);
    end
function close_button_Callback(hObject, eventdata, handles)
    classification_adv_CloseRequestFcn(hObject, eventdata, handles);
    
%% Refresh
function refresh_classadv_Callback(hObject, eventdata, handles)
    project_path = get(handles.classification_adv,'UserData');
    project_path = char_project_path(project_path);
    %find the number of folders inside the classification folder
    f = {};
    folders = dir(fullfile(project_path,'classification'));
    for i = 3:length(folders)
        if folders(i).isdir
            %check if there is at least one MAT file inside
            n_path = fullfile(project_path,'classification',folders(i).name);
            if ~isempty(dir(fullfile(n_path,'*.mat')))
                f = [f,folders(i).name];
            end
        end
    end
    if ~isempty(f)
        set(handles.select_groups,'String',f);
        set(handles.select_groups,'Value',1);
    end
    

%%%% Classifiers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Button
function generate_classifiers_Callback(hObject, eventdata, handles) 
    project_path = get(handles.classification_adv,'UserData');
    num_clusters = get(handles.default_clusters,'String'); 
    %get selected segmentation
    idx = get(handles.select_segmentation,'Value');
    selected_seg = get(handles.select_segmentation,'String');
    selected_seg = selected_seg{idx};
    %get selected segmentation labels
    idx = get(handles.select_labels,'Value');
    selected_labels = get(handles.select_labels,'String');
    selected_labels = selected_labels{idx};
    %generate the classifiers
    error = execute_classification(project_path,selected_seg,selected_labels,num_clusters);
    refresh_classadv_Callback(hObject, eventdata, handles);
    if ~error
        msgbox('Operation successfully completed','Success');
    end  
%Variables
function select_segmentation_Callback(hObject, eventdata, handles)
function select_segmentation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function select_labels_Callback(hObject, eventdata, handles)
function select_labels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function default_clusters_Callback(hObject, eventdata, handles)
function default_clusters_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%% MERGING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Buttons
function rule_options_Callback(hObject, eventdata, handles)  
    defaultVal = get(handles.rule_options,'UserData');
    mrule = get(handles.merge_rule,'String');
    idx = get(handles.merge_rule,'Value');
    mrule = mrule{idx};
    if isequal(mrule,'Majority Voting');
        error = 1;
        prompt = 'Specify threshold (0 to 100)';
        title = 'MajVot';
        lines = 1;
        default = {num2str(defaultVal)};
        answer = str2double(inputdlg(prompt,title,lines,default));
        try
            if answer >= 0 && answer <= 100
                set(handles.rule_options,'UserData',answer);
                error = 0;
            end
        catch
        end
        if error && ~isempty(answer)
            set(handles.rule_options,'UserData',0);
            errordlg('Wrong input. Threshold is set to 0 (default)','Threshold Error');
        end
    end
    
function generate_merge_Callback(hObject, eventdata, handles)
    project_path = get(handles.classification_adv,'UserData');
    sample = str2double(get(handles.class_per_group,'String'));
    iterations = str2double(get(handles.iterations,'String'));
    if isnan(sample) || isnan(iterations)
        errordlg('Wrong or unspecified input(s) for Classifiers per Group and/or Iterations.','Error');
        return
    end
    %we have only one rule for now thus the following lines are not needed
    %mrule = get(handles.merge_rule,'String');
    %idx = get(handles.merge_rule,'Value');
    %mrule = mrule(idx);
    extra_options = get(handles.rule_options,'UserData');
    class = get(handles.select_groups,'String');
    idx = get(handles.select_groups,'Value');
    class = class(idx);
    clusters = get(handles.specified_classifiers,'UserData');
    if isequal(clusters,0) % no specified classifiers
        error = execute_Mclassification(project_path, class, sample, iterations, extra_options);  
    else
        if length(idx) ~= 1 % cannot have specified classifiers and multiple classifications
            choice = questdlg('Specified classifiers have been selected, proceeding with multiple classifications will erase them. Would you like to continue?','Conflict','Yes','No','No');
            if isequal(choice,'Yes')
                error = execute_Mclassification(project_path, class, sample, iterations, extra_options);  
            else
                return;
            end
        else
            if length(clusters) > sample
                errordlg('The number of specified classifiers is larger than the specified sample.','Error');    
            else
                error = execute_Mclassification(project_path, class, sample, iterations, extra_options, clusters);
            end
        end 
    end
    if ~error
        msgbox('Operation successfully completed','Success');
    end
    
function specified_classifiers_Callback(hObject, eventdata, handles)
    project_path = get(handles.classification_adv,'UserData');
    project_path = char_project_path(project_path);
    class = get(handles.select_groups,'String');
    idx = get(handles.select_groups,'Value');
    if length(idx) ~= 1
        errordlg('This option is available if one classification is selected from the list.','Error');
    end
    class = class{idx};
    if isempty(class) || isequal(class,'')
        errordlg('No classifiers folder selected','Error');
    end
    class_path = fullfile(project_path,'classification',class);
    if ~exist(class_path,'dir')
        errordlg('Specified folder does not exist','Error');
    end
    obj = dir(fullfile(class_path,'*.mat'));
    str = {obj.name};
    [num,idx] = sort_classifiers(str);
    str = str(:,idx); %sorted list by number of clusters
    str = ['None',str]; %first element is 'None'
    pre = get(handles.specified_classifiers,'UserData');
    if pre == 0
        pre = 1;
    end
    [s,v] = listdlg('PromptString','Select classifier(s):',...
                    'SelectionMode','multiple',...
                    'ListString',str,'InitialValue',pre); 
    % if cancel/X is pressed or 'None' is selected return            
    if v == 0 || ~isempty(find(s==1))
        return
    else
        %remove the 'None' and fix indexing
        s = s-1; 
        clusters = num(s); 
    end
    set(handles.specified_classifiers,'UserData',sort(clusters));
    
       
%Variables
function select_groups_Callback(hObject, eventdata, handles)
function select_groups_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function class_per_group_Callback(hObject, eventdata, handles)
function class_per_group_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function iterations_Callback(hObject, eventdata, handles)
function iterations_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function merge_rule_Callback(hObject, eventdata, handles)
function merge_rule_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
