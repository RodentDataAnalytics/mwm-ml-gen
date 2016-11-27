function [error,fpath] = browse_create_labels_file(table,varargin)
%BROWSE_CREATE_LABELS_FILE

    error = 1;  
    % propose file name
    %time = fix(clock);
    %formatOut = 'yyyy-mmm-dd-HH-MM';
    time  = datetime('now');
    formatOut = 'dd-mmm-yyyy-HH-MM';
    time = datestr((time),formatOut);
    idx = strfind(time,'-');
    time(idx(end-1)) = 'h';
    time(idx(end)) = 'm';
    time = regexprep(time,'[^\w'']','');
    if ~isempty(varargin)
        path = char(varargin{2});
        file = strcat('labels_',varargin{1});
        pr = strcat('A file with name <',file,'> will be generated inside the project folder. Would you like to add a note to the name of the file? Allowed characters: A-Z, a-z, 0-9');
        %save note for user
        note = inputdlg(pr,'Input Note',1,{time});
        if isempty(note)
            error = 0;
            fpath = 0;
            return;
        end
        %remove spaces and special characters
        note{1} = regexprep(note{1},'[^\w'']','');
        if isempty(note{1})
            file = strcat(file,'.csv');  
        else
            file = strcat(file,'-',note,'.csv');
        end
        if iscell(file)
            file = file{1};
        end
        fpath = fullfile(path,file);
    else
        [file,path] = uiputfile('*.csv','Save segments labels',strcat('labels_',time));
        fpath = strcat(path,file);
    end
    if file == 0
        return;
    end
    % create the file
    try
        fid = fopen(fpath,'w');
        fclose(fid);      
        % save the labels to the file
        writetable(table,fpath,'WriteVariableNames',1);
        error = 0;
    catch
        errordlg('Cannot create file for saving the data');
    end   
end

