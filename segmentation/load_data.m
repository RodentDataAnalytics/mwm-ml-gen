function [ traj, terminate ] = load_data(inst,path,varargin)
%LOAD_DATA loads the trajectory data found in the folder specified by user
    
    terminate = 0;
    en_calibration = 0;
    
    f = dir(fullfile(path));
    % find if we need calibration
    for i = 3:length(f)
        if f(i).isdir == 0
            if isequal(f(i).name,'_cal_data.mat')
                load([fullfile(path),'/',f(i).name]);
                if exist('cal_data','var')
                    en_calibration = 1;
                else
                    error('Could not load calibration data');
                end    
            end
        end
    end    
    % take the first folder
    for k = 3:length(f)
        if f(k).isdir == 1
            if en_calibration
                % f(k).name, cal_data, 1 --> dir name, cal_data of this dir
                % calibration method
                traj = set_data( [path '/' f(k).name], inst.FORMAT, inst.TRAJECTORY_GROUPS, inst.COMMON_PROPERTIES, 1, f(k).name, cal_data, 1);
            else    
                traj = set_data( [path '/' f(k).name], inst.FORMAT, inst.TRAJECTORY_GROUPS, inst.COMMON_PROPERTIES, 1, varargin{:});
            end
            break;
        end
    end 
    % append the other folders
    i = 2;
    j = k;
    while i <= inst.COMMON_SETTINGS{1,2}{1,1} && k+i-1 <= length(f);
        if f(k+i-1).isdir ~= 1
            k = k+1;
        else
            if en_calibration
                % f(k).name, cal_data, 1 --> dir name, cal_data of this dir
                % calibration method
                traj = traj.append(set_data( [path '/' f(k+i-1).name], inst.FORMAT, inst.TRAJECTORY_GROUPS, inst.COMMON_PROPERTIES, i, f(k+i-1).name, cal_data), 1);     
            else
                traj = traj.append(set_data( [path '/' f(k+i-1).name], inst.FORMAT, inst.TRAJECTORY_GROUPS, inst.COMMON_PROPERTIES, i, varargin{:} )); 
            end
            k = j;
            i = i+1;
        end    
    end 

    % If the published results are required
    if ~isempty(varargin)
        if isequal(varargin{1,1},'original_data')
            % select only animal groups 1 and 2 
            group = arrayfun( @(t) t.group, traj.items);                       
            traj = trajectories(traj.items(group >= 1 & group <= 2));
        end
    end    

    % If no trajectories were loaded exit
    if exist('traj')
        if isempty(traj.items)
            traj = [];
            terminate = 1;
        end    
    elseif ~exist('traj') 
        traj = [];
        terminate = 1;  
    end    
end