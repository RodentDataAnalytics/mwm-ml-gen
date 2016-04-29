function [ data ] = trajectory_calibration_data( trajfile, dirname, center_x, center_y, arena_r )
%TRAJECTORY_CALIBRATION_DATA Given a trajectory file and a directory
%containing snapshots (screenshots) of the same trajectory gives back a set
%of calibration points for correcting the trajectory
    data = [];

    % first set: "real" points (from screenshots)
    pts1 = trajectory_points_from_snapshots(dirname);
    % second set: distorted points (from what Ethovisipn exports)
    [~, ~, pts2] = read_trajectory_ethovision(trajfile);
    
    for i = 1:length(pts1)
        % point in the distorted trajectory
        pt = pts2(find(pts2(:,1) == pts1(i,1)), :);
        if isempty(pt)
            error(sprintf('Point %.1f not found in trajectory %s', pts1(i,1), trajfile));
        end
        dx = pts1(i,2)*arena_r - (pt(2) - center_x);
        dy = pts1(i,3)*arena_r - (pt(3) - center_y);
        % sanity check
        if abs(dx) > 85 | abs(dy) > 85
            error('Something wrong?');
        end
        data = [data; pt(2:3), dx, dy];
    end         
    %data
end