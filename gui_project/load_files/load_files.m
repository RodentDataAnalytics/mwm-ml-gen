function [data, table, session] = load_files(path, animal_id, rec_time, centre_x, centre_y)
%LOAD_FILES loads all data from specified folder and subfolders

    %Initialize and get all the files/subfolders of the main folder
    files = dir(path);
    dir_indexes = [];
    data = {};
    table = {};
    %loading bar
    fname = strsplit(path,{'/','\'});
    fname = fname{end};
    str = ['Loading files from folder ',fname];
    h = waitbar(0,str,'Name','Importing...');
    
    %calibration (if needed)
    mat_files = dir(fullfile(path,'*.mat'));
    for i = 1:length(mat_files)
        if isequal(mat_files(i).name,'calibration_data.mat');
            load(fullfile(path,mat_files(i).name));
        end
    end    
    
    %current folder
    k = 1;
    session = 1;
    for i = 3:length(files)
        if files(i).isdir == 1
            dir_indexes = [dir_indexes,i];
        else
            fn = fullfile(path, files(i).name);
            %skip temp open files (names starting with '~')
            [~, check, ~] = fileparts(fn);
            if isequal(check(1),'~')
                continue;
            end  
            [id, pts, error] = parse_data(fn, animal_id, rec_time, centre_x, centre_y);
            %if calibrate
            if exist('calibration_data','var') == 1
                pts = calibrate_trajectory(pts,calibration_data{1},1);
            end
            if error == 1 %failed to find valid id or points
                if isnumeric(id) && ~isnan(id)
                    table = [table;{files(i).name,session,id,NaN,NaN}];
                else
                    table = [table;{files(i).name,session,NaN,NaN,1}];
                end
            elseif error == 2 %unsupported file extension
                continue
            else
                table = [table;{files(i).name,session,id,NaN,1}];
            end    
            data{k,session} = {files(i).name, session, id, pts};
            k = k+1;
        end 
        waitbar(i/length(files));
    end
    close(h);
    if ~isempty(data)
        session = session + 1;
    end    
        
    %subfolders of the given folder
    for i = 1:length(dir_indexes)
        %loading bar
        str = ['Loading files from the subfolder ',files(dir_indexes(i)).name];
        h = waitbar(0,str,'Name','Importing...');
        files_ = dir(fullfile(path,files(dir_indexes(i)).name));
        k = 1;
        for j = 3:length(files_)
            fn = fullfile(path,files(dir_indexes(i)).name, files_(j).name); 
            %skip temp open files (names starting with '~')
            [~, check, ~] = fileparts(fn);
            if isequal(check(1),'~')
                continue;
            end    
            [id, pts, error] = parse_data(fn, animal_id, rec_time, centre_x, centre_y); 
            %if calibrate
            if exist('calibration_data','var') == 1
                pts = calibrate_trajectory(pts,calibration_data{i},1);
            end
            if error == 1
                if isnumeric(id) && ~isnan(id)
                    table = [table;{files_(j).name,session,id,NaN,NaN}];
                else
                    table = [table;{files_(j).name,session,NaN,NaN,1}];
                end
            elseif error == 2
                continue
            else    
                table = [table;{files_(j).name,session,id,NaN,1}];
            end     
            data{k,session} = {files_(j).name, session, id, pts};
            k = k+1;
            waitbar(j/length(files_));
        end
        close(h);
        session = session + 1;
    end
    session = session - 1;
end

