function [ traj ] = file_paths( inst )
% Generalized code for reading the data needs to be tested with new
% datasets

    path = inst.TRAJECTORIES_DIR;
    % 1. find the number of the dirs
    filelist = dir(inst.TRAJECTORIES_DIR);
    counter = 0;
    k=1;
    for i = 1:length(filelist)
        if filelist(i).isdir
            dirs{k} = filelist(i).name
            k=k+1;
        end
    end 
    % 2. take only dirs with name starting with = 'set' + a numeric
    for i = 1:length(dirs)
        name = dirs{1,i}
        if strcmp(name(1),'s') && strcmp(name(2),'e') && strcmp(name(3),'t')
            num = str2num(name(4:end));
            if ~isempty(num)
                counter = counter+1;
            end
        end
    end    

    if counter > 0
        traj = load_trajectories_ethovision(inst, [inst.TRAJECTORIES_DIR '/' strcat('set','1')], 1, ...
            {[path '/' strcat('screenshots/set','1')]}, {[path '/' strcat('set',1)]}, 'DeltaX', -100, 'DeltaY', -100 ...
        );
        for i=2:counter
            traj = traj.append(load_trajectories_ethovision(inst, [path '/' strcat('set',num2str(counter))], counter, ...
                {[path '/' strcat('screenshots/set',num2str(counter))]}, {[path '/' strcat('set',num2str(counter))]}, 'DeltaX', -100, 'DeltaY', -100) ...
            );
        end
    end    
    
end

