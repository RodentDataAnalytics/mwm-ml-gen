function [ error ] = data_consistency( inst )
%DATA_CONSISTENCY checks if the loaded data are correct.
% a) We should have each animal id sum(total_number_of_trials) times.
% b) If an animal id was used in multiple groups then we should have this
%    animal id (number_of_times_used * sum(total_number_of_trials)) times.

    error = 0;
    tps = inst.COMMON_SETTINGS{1,4}{1,1};
    number_of_trials = sum(tps);

    ids = arrayfun( @(t) t.id, inst.TRAJECTORIES.items);
    number_of_animals = unique(ids);
    groups = arrayfun( @(t) t.group, inst.TRAJECTORIES.items);

    for i = 1:length(number_of_animals)
        temp = find(ids == number_of_animals(i));
        % if the number of same ids equal the number of trials -> OK
        if length(temp) == number_of_trials
            continue;
        % else check if an animal id was used in multiple groups
        else
            temp_2 = groups(temp);
            unique_temp_2 = unique(temp_2);
            for j = 1:unique_temp_2
                temp_3 = find(temp_2 == unique_temp_2(j));
                %if it has been used in multiple groups continue
                if length(temp_3) == number_of_trials;
                    continue;
                else
                    error = 1;
                    return;
                end
            end    
        end    
    end    
end

