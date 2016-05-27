function [ inst, error ] = fix_trials_numbering( inst )
%FIX_TRIALS_NUMBERING fixes the numbering of the trials.
% e.g. 4trials/day, for animal id x we will have:
% day 1: 1,2,3,4. day 2: 5,6,7,8. day 3: 9,10,11,12.

    % Check data consistency
%     error = data_consistency(inst);
%     if error
%         return;
%     end

    % Total number of trials
    tps = inst.COMMON_SETTINGS{1,4}{1,1};
    if isstring(tps) || ischar(tps)
        number_of_trials = sum(str2num((tps)));
    elseif iscell(tps)
        number_of_trials = sum(cell2mat((tps)));
    else
        number_of_trials = sum(tps);
    end    
    
    % Days
    number_of_days = inst.COMMON_SETTINGS{1,8}{1,1};
    if isstring(number_of_days) || ischar(number_of_days)
        number_of_days = str2num((number_of_days));
    elseif iscell(number_of_days)
        number_of_days = cell2mat((number_of_days));
    end 

    ids = arrayfun( @(t) t.id, inst.TRAJECTORIES.items);
    sessions = arrayfun( @(t) t.session, inst.TRAJECTORIES.items);
    
    number_of_animals = unique(ids);
    excluded_ids = {};
    error = {};
    
    % check if animal id exists number_of_trials times in each session
    number_of_sessions = unique(sessions);
    for i = 1:length(number_of_sessions)
        % check if animal id exists number_of_trials times
        for a = 1:length(number_of_animals)
            current_id = find(ids == number_of_animals(a));
            if length(current_id) == number_of_trials
                continue
            % check if an animal id was used in multiple groups
            else
                multi_sessions = sessions(current_id);
                unique_multi_sessions = unique(multi_sessions);
                for w = 1:length(unique_multi_sessions)
                    ch = find(multi_sessions == unique_multi_sessions(w));
                    if length(ch) ==  number_of_trials
                        break;
                    else
                        % save this id to exclude it later
                        excluded_ids{i,a} = number_of_animals(a);
                        excluded_ids = excluded_ids(~cellfun('isempty',excluded_ids));  
                        error{i} = excluded_ids;
                        break;
                    end    
                end  
            end
        end
        % exclude animal ids if necessary                      
        for k = 1:length(excluded_ids)
            if ~isempty(excluded_ids{1,k})
                ids = arrayfun( @(t) t.id, inst.TRAJECTORIES.items);
                sessions = arrayfun( @(t) t.session, inst.TRAJECTORIES.items);
                inst.TRAJECTORIES = trajectories(inst.TRAJECTORIES.items(ids ~= excluded_ids{1,k} & sessions == i));
            end
        end    
    end
    
    % Re-initialize
    ids = arrayfun( @(t) t.id, inst.TRAJECTORIES.items);
    groups = arrayfun( @(t) t.group, inst.TRAJECTORIES.items);
    trials = arrayfun( @(t) t.trial, inst.TRAJECTORIES.items);
    sessions = arrayfun( @(t) t.session, inst.TRAJECTORIES.items);
    
    number_of_animals = unique(ids);
    number_of_groups = unique(groups);
    
    % fix trials numbering
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
    
    % fix days numbering
    number_of_sessions = unique(sessions);
    days = [];
    for i = 1:length(number_of_sessions)
        ses = find(sessions == number_of_sessions(i));
        days_ = length(ses)/number_of_days;
        temp_days = [];
        for j = 1:number_of_days
            for k = 1:days_
                temp_days(k) = j;
            end
            days = [days, temp_days];
        end  
    end
            
    % Assign fixed trials
    for i = 1:length(inst.TRAJECTORIES.items)
        inst.TRAJECTORIES.items(i).trial = trials(i);
        inst.TRAJECTORIES.items(i).day = days(i);
    end    
        
end

