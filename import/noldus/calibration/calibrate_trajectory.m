function [ out ] = calibrate_trajectory( pts, cal_data )
%CALIBRATE_TRAJECTORY Calibrates a set of points using linear interpolation
%defined by the calibration data
    
    % calibration data should be a Nx4 matrix where each row has format 
    % (x, y, dx, dy)
    warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
    Fx = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,3), 'linear', 'linear');
    Fy = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,4), 'linear', 'linear');                   
    x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
    y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
    warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
    out = [pts(:,1), x, y];
end