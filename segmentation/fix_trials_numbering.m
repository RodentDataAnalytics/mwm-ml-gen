function [ inst, error ] = fix_trials_numbering( inst )
%FIX_TRIALS_NUMBERING fixes the numbering of the trials.
% e.g. 4trials/day, for animal id x we will have:
% day 1: 1,2,3,4. day 2: 5,6,7,8. day 3: 9,10,11,12.

    % Check data consistency
    error = data_consistency(inst);
    if error
        return;
    end

    % Total number of trials
    tps = inst.COMMON_SETTINGS{1,4}{1,1};
    number_of_trials = sum(tps);

    ids = arrayfun( @(t) t.id, inst.TRAJECTORIES.items);
    groups = arrayfun( @(t) t.group, inst.TRAJECTORIES.items);
    trials = arrayfun( @(t) t.trial, inst.TRAJECTORIES.items);
    
    number_of_animals = unique(ids);
    number_of_groups = unique(groups);
    
    ids_groups = zeros(2,length(ids));
    ids_groups(1,:) = ids;
    ids_groups(2,:) = groups;

    for i = 1:length(number_of_animals)
        temp = find(ids == number_of_animals(i));
        if length(temp) == number_of_trials
            for j = 1:number_of_trials
                trials(temp(j)) = j;
            end
        % if temp > number_of_trials then this animal id exist in multiple
        % animal groups.
        else
            for j = 1:length(number_of_groups)
                % find this animal id for only group j
                temp_2 = find(ids_groups(1,:) == ids(temp(1)) & ids_groups(2,:) == number_of_groups(j));
                for k = 1:length(temp_2)
                    trials(temp_2(k)) = k;
                end
            end
        end
    end
    
    % Assign fixed trials
    for i = 1:length(inst.TRAJECTORIES.items)
        inst.TRAJECTORIES.items(i).trial = trials(i);
    end    
        
end

