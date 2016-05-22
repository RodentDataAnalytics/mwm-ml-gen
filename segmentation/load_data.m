function [ traj, terminate ] = load_data(inst,path,varargin)
%LOAD_DATA loads the trajectory data found in the folder specified by user
    
    terminate = 0;

    f = dir(fullfile(path));
    % take the first folder
    for k = 3:length(f)
        if f(k).isdir == 1
            traj = set_data( [path '/' f(k).name], inst.FORMAT, inst.TRAJECTORY_GROUPS, inst.COMMON_PROPERTIES, 1, varargin{:} );
            break;
        end
    end 
    % append the other folders
    i = 2;
    j = k;
    while i <= inst.COMMON_SETTINGS{1,2}{1,1} && i <= length(f);
        if f(k+i-1).isdir ~= 1
            k = k+1;
        else
            traj = traj.append(set_data( [path '/' f(k+i-1).name], inst.FORMAT, inst.TRAJECTORY_GROUPS, inst.COMMON_PROPERTIES, i, varargin{:} )); 
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
    if isempty(traj.items)
        disp('No trajectories found in the specified path');
        terminate = 1;
    end       
end