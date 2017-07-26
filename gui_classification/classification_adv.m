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
    set(handles.select_groups, 'Min', 0, 'Max', 0);
    set(handles.specified_classifiers,'UserData',0);
    %keep the default button color
    def_color = get(handles.close_button,'BackgroundColor');
    set(handles.close_button,'UserData',def_color);
    refresh_classadv_Callback(hObject, eventdata, handles)
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
    
%%%% CLASSIFIERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Button
function generate_classifiers_Callback(hObject, eventdata, handles) 
    [error,project_path,selected_seg,selected_labels,num_clusters] = initialize_classification(handles,eventdata);
    if error || isempty(project_path)
        return
    end
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
                set(handles.specified_classifiers,'BackgroundColor',[1,0,0]);
                error = 0;
            end
        catch
        end
        if error && ~isempty(answer)
            set(handles.rule_options,'UserData',0);
            def_color = get(handles.close_button,'UserData');
            set(handles.rule_options,'BackgroundColor',def_color);
            errordlg('Wrong input. Threshold is set to 0 (default)','Threshold Error');
        end
    end
    
function generate_merge_Callback(hObject, eventdata, handles)
    project_path = char_project_path(get(handles.classification_adv,'UserData'));
    sample = str2double(get(handles.class_per_group,'String'));
    iterations = str2double(get(handles.iterations,'String'));
    if isnan(sample) || isnan(iterations)
        errordlg('Wrong or unspecified input(s) for Classifiers per Group and/or Iterations.','Error');
        return
    end
    if sample < 1 || iterations < 1
        errordlg('Value of Classifiers per Group and/or Iterations cannot be less than 1.','Error');
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
        clusters = dir(char_project_path(fullfile(project_path,'classification',class,'*.mat')));
        if length(clusters) < sample
            errordlg('The number of specified sample is larger than the number of specified classifiers. ','Error')
            return
        elseif length(clusters) == sample && iterations > 1
            warndlg('The number of specified sample and the number of specified classifiers are equal. Only one iteration will be performed','Warning');    
            iterations = 1;       
        end        
        error = execute_Mclassification(project_path, class, sample, iterations, extra_options);  
    else
        % it will never go inside the first 'if' multiple selection has
        % been disable!
        if length(idx) ~= 1 % cannot have specified classifiers and multiple classifications
            choice = questdlg('Specified classifiers have been selected, proceeding with multiple classifications will erase them. Would you like to continue?','Conflict','Yes','No','No');
            if isequal(choice,'Yes')
                error = execute_Mclassification(project_path, class, sample, iterations, extra_options);  
            else
                return;
            end
        else
            if length(clusters) < sample
                errordlg('The number of specified sample is larger than the number of specified classifiers.','Error')
                return
            elseif length(clusters) == sample && iterations > 1
                warndlg('The number of specified sample and the number of specified classifiers are equal. Only one iteration will be performed','Warning');    
                iterations = 1;       
            end
            error = execute_Mclassification(project_path, class, sample, iterations, extra_options, 'CLUSTERS', clusters);
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
        tmp = 1;
    else
        tmp = zeros(1,length(pre));
        for t = 1:length(pre)
            tmp(t) = find(num==pre(t))+1;
        end
    end
    [s,v] = listdlg('PromptString','Select classifier(s):',...
                    'SelectionMode','multiple',...
                    'ListString',str,'InitialValue',tmp); 
    % if cancel/X is pressed or 'None' is selected return            
    if v == 0 || ~isempty(find(s==1))
        set(handles.specified_classifiers,'UserData',0);
        def_color = get(handles.close_button,'UserData');
        set(handles.specified_classifiers,'BackgroundColor',def_color);
        return
    else
        %remove the 'None' and fix indexing
        s = s-1; 
        clusters = num(s); 
    end
    set(handles.specified_classifiers,'UserData',sort(clusters));
    set(handles.specified_classifiers,'BackgroundColor',[1,0,0]);
    
       
%Variables
function select_groups_Callback(hObject, eventdata, handles)
    %reset Rule options and Specified
    def_color = get(handles.close_button,'UserData');
    set(handles.rule_options,'UserData',0);
    set(handles.rule_options,'BackgroundColor',def_color);
    set(handles.specified_classifiers,'UserData',0);
    set(handles.specified_classifiers,'BackgroundColor',def_color);
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
