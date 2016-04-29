function [ pts ] = trajectory_points_from_snapshots( dirname )
%TRAJECTORY_POINTS_FROM_SNAPSHOTS Processes a directory with a series of
%trajectory snapshots. Returns a list of time and coordinates for the
%trajectory (one set per image)
    files = dir(fullfile(dirname, '/*.png') );
          
    fprintf('Processing %d swimming path snapshots (%s)...\n', length(files), dirname);
    
    pts = [];                
    
    for i = 1:length(files)
        fprintf('%s...\n', files(i).name);
        t = sscanf(files(i).name,'%dms.png');
        [x, y] = trajectory_snapshot_position(strcat(dirname, '/', files(i).name), 0);
        pts = [pts; double(t)/1000., x, y];
    end
end