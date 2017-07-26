function results_calibration_graphs( cal_data, i, count, output )
% Calculates the calibration error as a function of the number of
% calibration points.

%INPUT:
% cal_data: cell array containing calibration data (extracted from
%           EthoVision snapshots). Each two cells have the format:
%           {session_name_1, cal_data_1, ... ,session_name_N, cal_data_N}
%           Each cal_data_n:
%           Nx4 double, [X | Y | dX | dY], where dX = X-x and dY = Y-y
% i: specifies the n of cal_data_n.
% count: used to specify which calibration faction was used.
% output: output folder

%Author: Tiago V. Gehring
%Edited by: Avgoustinos Vouros


    % cross validation     
    i = i+1;
    n = length(cal_data{i});
    data = cal_data{i};        
    pts = [];
    warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
    for s = 0.1:0.1:1            
        err = [];
        for rep = 1:10                                   
            cv = cvpartition(randsample(1:n, floor(s*n)), 'k', 10);
            % 1 - run the standard k-means clustering algorithm
            for j = 1:cv.NumTestSets % perforn a 10-fold stratified cross-validation                                        
                training = data(cv.training(j), :);
                test = data(cv.test(j), :);            
                
                switch count
                    case 1
                        % compute interpolation functions
                        Fx = scatteredInterpolant(training(:,1), training(:,2), training(:,3), 'linear', 'linear');
                        Fy = scatteredInterpolant(training(:,1), training(:,2), training(:,4), 'linear', 'linear');                       
                        % compute error
                        err = [err; (Fx(test(:, 1), test(:,2)) - test(:,3))];
                        err = [err; (Fy(test(:, 1), test(:,2)) - test(:,4))];        
                end        
            end
        end
        pts = [pts; floor(s*n*0.9), mean(abs(err)), 1.96*std(abs(err))/sqrt(length(err) - 1)];
    end
    warning('on', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
    figure('name', sprintf('Calibration error (set %d)', count));
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', 10, 'LineWidth', 1);
    errorbar(pts(:,1), pts(:,2), pts(:,3), 'k:', 'LineWidth', 1);
    xlabel('number of calibration points');
    ylabel('error [cm]');        
    export_figure(1, gcf, output, sprintf('calibration_error%d', count));
end

