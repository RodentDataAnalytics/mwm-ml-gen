function [ TRAJECTORIES ] = load_data(inst)
%LOAD_DATA loads the trajectory data found in the folder specified by user

% find a unique id for the directory contents by hashing all the file
% names / directories within it 
id = 0;
files = dir(inst.TRAJECTORIES_DIR);
for fi = 1:length(files)
    if files(fi).isdir
        name = files(fi).name;
        if strncmpi(name, 'set', 3)
            fn = dir(strcat(inst.TRAJECTORIES_DIR,'\',name))  
            id = hash_combine(id, hash_value(length(fn)));
        end
    end    
end

% mount the path cache\trajetories_id
fn = fullfile(inst.CACHE, ['trajectories_', num2str(id), '.mat']);
% if it exists -> trajectories already cached, so just load them.
if exist(fn, 'file')            
    load(fn);
    TRAJECTORIES = traj;
else
    % file_paths (inst) -> generalized, needs testing with other data
    % have to load them
    path = inst.TRAJECTORIES_DIR;
    traj = load_trajectories_ethovision(inst, [inst.TRAJECTORIES_DIR '/' 'set1'], 1, ...
        {[path '/' 'screenshots/set1'], [path '/' 'screenshots/set2']}, {[path '/' 'set1'], [path '/' 'set2']}, 'DeltaX', -100, 'DeltaY', -100 ...
    );
    traj = traj.append(load_trajectories_ethovision(inst, [path '/' 'set2'], 2, ...
        {[path '/' 'screenshots/set1'], [path '/' 'screenshots/set2']}, {[path '/' 'set1'], [path '/' 'set2']}, 'DeltaX', -100, 'DeltaY', -100) ...
    );
    traj = traj.append(load_trajectories_ethovision(inst, [path '/' 'set3'], 3, ...
        { [path '/screenshots/set3'] }, { [path '/' 'set3'] }, 'DeltaX', -100, 'DeltaY', -100));
    
    %% FOR TESTING ONLY - COMMENT IT OTHERWISE %%
    % This code is used to keep only animal groups 1 and 2 as in the
    % original code.
    group = arrayfun( @(t) t.group, traj.items);                         
    traj = trajectories(traj.items(group >= 1 & group <= 2));  
    % END TESTING %
    
    TRAJECTORIES = traj;
    
    % save for next time   
    save(fn, 'traj');
    
end

end