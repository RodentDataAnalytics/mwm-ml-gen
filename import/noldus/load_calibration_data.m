function cal_data = load_calibration_data(paths, data_paths)
%LOAD_CALIBRATION_DATA Summary of this function goes here
%   Detailed explanation goes here
    addpath(fullfile(fileparts(mfilename('fullpath')), '/calibration'));
    
    assert( length(paths) == length(data_paths) );
    cal_data = [];
            
    for ipath = 1:length(paths)
        % load calibration data            
        files = dir(paths{ipath});                
        for j = 3:length(files)
            if files(j).isdir
               % get day and track number from directory
               temp = sscanf(files(j).name, 'day%d_track%d');
               day = temp(1);
               track = temp(2);
               % find corresponding track file
               fn = fullfile(data_paths{ipath}, sprintf('day%d_%.4d_00.csv', day, track));
               if ~exist(fn, 'file')
                   error('Non-existent file');
               end
               cal_data = [cal_data; trajectory_calibration_data(fn, fullfile(paths{ipath}, files(j).name), 100, 100, 100)];                                      
            end
        end
    end
end