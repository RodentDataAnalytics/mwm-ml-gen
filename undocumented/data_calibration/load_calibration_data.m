function [ cal_data ] = load_calibration_data(paths,format)
%LOAD_CALIBRATION_DATA calibrates trajectory data and returns calibrated
%data.

% INPUT
% paths{1} = trajectory data
% format{1} = rec time field
% format{2} = x field
% format{3} = y field
% format{4} = arena
% format{5} = x
% format{6} = y

% OUTPUT:
% cal_data (saved as: _cal_data): 1xN cell array, each second cell contains
% a Nx4 double matrix.
    % column 1: X coordinates
    % column 2: Y coordinates
    % column 3: dx, X difference between snapshot and trajectory data
    % column 4: dy, Y difference between snapshot and trajectory data
    
    traj_files = dir(paths{1});
    temp_cal_data = [];
    cal_data = {};
    h = waitbar(0,'Calibrating trajectory data...','Name','Calibration');
    count = 1;
    % for each folder found (session)
    for k = 3:length(traj_files)
        if traj_files(k).isdir
            str = ['Directory: ',traj_files(k).name];
            count = count+1;
            waitbar(0,h,str);
            % take the path of the folder
            fn = strcat(paths{1},'/',traj_files(k).name);
            % take all the files (*.csv OR *.CSV 0R *.xlsx OR *.XLSX)
            ext = {'/*.csv','/*.CSV','/*.xlsx','/*.XLSX'};
            for i = 1:length(ext)
                files = dir(fullfile(fn, ext{i}));
                if ~isempty(files)
                    break;
                end    
            end
            % check if there is a '_snapshots' folder
            if exist(strcat(fn,'/','_snapshots'), 'dir');
                snap_files = dir(strcat(fn,'/','_snapshots'));
            else
                continue;
            end  
            % if there is a '_snapshots' folder
            for j = 3:length(snap_files)
                if snap_files(j).isdir
                    str = strsplit(snap_files(j).name,'_');
                    try
                        track_snaps = str2num(str{2});
                    catch
                        disp('Error parsing snapshots folder');
                        return;
                    end
                    % match traj file to snap folder
                    for i = 1:length(files)
                        str = strsplit(files(i).name,'_');
                        try
                            track = str2num(str{2});
                        catch
                            disp('Error parsing trajectory file');
                            return;
                        end
                        if track ~= track_snaps
                            continue;
                        else
                            traj_file = strcat(fn,'/',files(i).name);
                            snap_dir = strcat(fn,'/','_snapshots','/',snap_files(j).name);
                            new_data = trajectory_calibration_data(traj_file, snap_dir, format{1}, format{2}, format{3}, format{4}, format{5}, format{6});
                            if isempty(new_data)
                                continue;
                            end    
                            temp_cal_data = [temp_cal_data; new_data];
                        end    
                    end   
                else
                    continue;
                end
                waitbar(j/length(snap_files));
            end 
        end
        if ~isempty(temp_cal_data)
            cal_data = [cal_data, traj_files(k).name, temp_cal_data];
        end    
    end
    delete(h);
end

