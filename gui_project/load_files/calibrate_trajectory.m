function [ out ] = calibrate_trajectory( pts, cal_data, choice )
%CALIBRATE_TRAJECTORY Calibrates a set of points using linear interpolation
%defined by the calibration data

%INPUT:
% pts: data from the EthoVision exported files. Nx3 double, [time | x | y]
% cal_data: calibration data (extracted from EthoVision snapshots).
%           Nx4 double, [X | Y | dX | dY], where dX = X-x and dY = Y-y
% choice: selection of calibration method.

%OUTPUT:
% out: a set of calibrated x,y coordinates.
 
%Author: Tiago V. Gehring
%Edited by: Avgoustinos Vouros
    
switch choice
    case 1 % original
        % calibration data should be a Nx4 matrix where each row has format 
        % (x, y, dx, dy)
        warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
        Fx = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,3), 'linear', 'linear');
        Fy = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,4), 'linear', 'linear');   
        x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
        y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
        warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
        out = [pts(:,1), x, y];
%     case 2 % T,T,dx,lin,near   
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,3), 'linear', 'nearest');
%         Fy = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,4), 'linear', 'nearest');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];
%     case 3 % F,F,dx,lin,lin  
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,3), 'linear', 'linear');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,4), 'linear', 'linear');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];  
%     case 4 % F,F,dx,lin,near  
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,3), 'linear', 'nearest');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,4), 'linear', 'nearest');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];  
%     case 5 % F,F,T,lin,lin  
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,1), 'linear', 'linear');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,2), 'linear', 'linear');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y]; 
%     case 6 % F,F,T,lin,near  
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,1), 'linear', 'nearest');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,2), 'linear', 'nearest');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];  
%     case 7 % original 2-stage
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,3), 'linear', 'linear');
%         Fy = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,4), 'linear', 'linear');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         x = x + Fx(x, y);    
%         y = y + Fy(x, y);
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];
%     case 8 % T,T,dx,lin,near 2-stage   
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,3), 'linear', 'nearest');
%         Fy = scatteredInterpolant(cal_data(:,1), cal_data(:,2), cal_data(:,4), 'linear', 'nearest');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         x = x + Fx(x, y);    
%         y = y + Fy(x, y);
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];
%     case 9 % F,F,dx,lin,lin 2-stage 
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,3), 'linear', 'linear');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,4), 'linear', 'linear');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         x = x + Fx(x, y);    
%         y = y + Fy(x, y);
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];  
%     case 10 % F,F,dx,lin,near 2-stage   
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,3), 'linear', 'nearest');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,4), 'linear', 'nearest');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         x = x + Fx(x, y);    
%         y = y + Fy(x, y);
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];  
%     case 11 % F,F,T,lin,lin 2-stage  
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,1), 'linear', 'linear');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,2), 'linear', 'linear');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         x = x + Fx(x, y);    
%         y = y + Fy(x, y);
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y]; 
%     case 12 % F,F,T,lin,near 2-stage  
%         warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         Fx = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,1), 'linear', 'nearest');
%         Fy = scatteredInterpolant(cal_data(:,1)-cal_data(:,3), cal_data(:,2)-cal_data(:,4), cal_data(:,2), 'linear', 'nearest');   
%         x = pts(:,2) + Fx(pts(:, 2), pts(:, 3));    
%         y = pts(:,3) + Fy(pts(:, 2), pts(:, 3));
%         x = x + Fx(x, y);    
%         y = y + Fy(x, y);
%         warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
%         out = [pts(:,1), x, y];        
end    
end