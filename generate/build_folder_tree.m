function error = build_folder_tree(user_ppath, fname)
% BUILD_FOLDER_TREE 

    error = 1;
    user_ppath = char_project_path(user_ppath);
    ppath = fullfile(user_ppath,fname);

    % check if project already exists
    flag = 0;
    if exist(ppath,'dir') ~= 0
        choice = questdlg('Project already exists do you wish to overwrite it?', ...
                          'Overwrite?','Yes','No','No');
        switch choice
            case 'Yes'
                flag = 1;
            case 'No'
                return;
        end
    end
    % delete folder if already exists
    if flag
        rmdir(ppath,'s');
    end    
    % make the new folder    
    try
        [s,~,~] = mkdir(ppath);
        if ~s
            errordlg('Cannot create project. Specify a name without special characters','Error');
            return
        end
    catch
        errordlg('Cannot create project. Specify a name without special characters','Error');
        return
    end  
    % create the rest of the dirs
    labelsDir = fullfile(ppath,'labels');
    settingsDir = fullfile(ppath,'settings');
    segmentsDir = fullfile(ppath,'segmentation');
    classificationDir = fullfile(ppath,'classification');
    MclassificationDir = fullfile(ppath,'Mclassification');
    resultsDir = fullfile(ppath,'results');
    mkdir(labelsDir);
    mkdir(settingsDir);
    mkdir(segmentsDir);
    mkdir(classificationDir);
    mkdir(MclassificationDir);
    mkdir(resultsDir);
    % make a new config (cfg) file
    tmp_ppath = strcat(ppath,'/',fname,'.cfg');
    save(tmp_ppath);
    % get the current time and date
    time = fix(clock);
    formatOut = 'yyyy-mm-dd-HH-MM';
    time = datestr((time),formatOut);
    % open the file
    fid = fopen(tmp_ppath,'wt');
    % write date and folders ppaths
    fprintf(fid,'%s\n',time);
    fprintf(fid,'MainFolder:%s\n',ppath);
    fprintf(fid,'SettingsFolder:%s\n',settingsDir);
    fprintf(fid,'SegmentationFolder:%s\n',segmentsDir);
    fprintf(fid,'LabelsFolder:%s\n',labelsDir);
    fprintf(fid,'ClassificationFolder:%s\n',classificationDir);
    fprintf(fid,'MClassificationFolder:%s\n',MclassificationDir);
    fprintf(fid,'ResultsFolder:%s\n',resultsDir);
    fclose(fid);
    error = 0;
end

