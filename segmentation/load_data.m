function [ traj ] = load_data(inst,path,varargin)
%LOAD_DATA loads the trajectory data found in the folder specified by user

    % Determine if we work with the test data
    [pathstr,name,ext] = fileparts(path);
    if strcmp(name,'mwm_peripubertal_stress')
        traj = load_trajectories_ethovision(inst, [path '/' 'set1'], 1, ...
            {[path '/' 'screenshots/set1'], [path '/' 'screenshots/set2']}, {[path '/' 'set1'], [path '/' 'set2']}, 'DeltaX', -100, 'DeltaY', -100 ...
        );
        traj = traj.append(load_trajectories_ethovision(inst, [path '/' 'set2'], 2, ...
            {[path '/' 'screenshots/set1'], [path '/' 'screenshots/set2']}, {[path '/' 'set1'], [path '/' 'set2']}, 'DeltaX', -100, 'DeltaY', -100) ...
        );
        traj = traj.append(load_trajectories_ethovision(inst, [path '/' 'set3'], 3, ...
            { [path '/screenshots/set3'] }, { [path '/' 'set3'] }, 'DeltaX', -100, 'DeltaY', -100));
    end
    %else
        % waiting for new data format...
    %end
    
    % Selects only groups 1 and 2 (for testing purpose)
    if ~isempty(varargin)
        group = arrayfun( @(t) t.group, traj.items);                       
        traj = trajectories(traj.items(group >= 1 & group <= 2));  
    end
end