function [ data ] = trajectory_calibration_data( trajfile, dirname, TIME, X, Y, arena_r, center_x, center_y )
%TRAJECTORY_CALIBRATION_DATA Given a trajectory file and a directory
%containing snapshots (screenshots) of the same trajectory gives back a set
%of calibration points for correcting the trajectory

% TIME, X, Y                  = file fields
% arena_r, center_x, center_y = experiment properties

    data = [];

    % first set: "real" points (from screenshots)
    pts1 = trajectory_points_from_snapshots(dirname);
    % second set: distorted points (from what Ethovisipn exports)
    pts2 = parse_data_pts(trajfile, TIME, X, Y);
    
    % checking
    if isempty(pts1) || isempty(pts2)
        return;
    end    
    
    for i = 1:length(pts1)
        % point in the distorted trajectory
        pt = pts2(find(pts2(:,1) == pts1(i,1)), :);
        if isempty(pt)
            %error(sprintf('Point %.1f not found in trajectory %s', pts1(i,1), trajfile));
            warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
            a = strsplit(trajfile,{'\','/'});
            fprintf('Point %.1f was not found in trajectory %s. Bad snapshot: %d, ''%s''\n', pts1(i,1), a{1,end}, i, dirname);
            continue;
        end
        dx = pts1(i,2)*arena_r - (pt(2) - center_x);
        dy = pts1(i,3)*arena_r - (pt(3) - center_y);
        % sanity check
        if abs(dx) > 85 | abs(dy) > 85
            %error('Something wrong?');
            warning('off','MATLAB:printf:BadEscapeSequenceInFormat');
            fprintf('Sanity test failed. Bad snapshot: %d, ''%s''\n',i, dirname);
            continue;
        end
        data = [data; pt(2:3), dx, dy];
    end     
end