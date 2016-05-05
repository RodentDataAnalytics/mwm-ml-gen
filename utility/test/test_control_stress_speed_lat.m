function [ animals_ids, animals_trajectories_map ] = test_control_stress_speed_lat( map_, num_sessions, trials_per_session, group_a, group_b, ids, speed )
% This function is activated from 'animals' for the purpose of
% selecting the specific animals used in the paper for the 
% Friedman's test.
    
    [~,an_a] = size(group_a);
    [~,an_b] = size(group_b);
    animals_ids = {};
    animals_trajectories_map = {};
    
    for i=1:2
        map=map_{i};
        id=ids{i,1};
        if i==1
            nd = an_a - an_b;
            if nd > 0
                nd = max(nd, 0);
            else
                nd = max(0 + nd, 0);
            end
            for s = 1:num_sessions                    
                ti = (s - 1)*trials_per_session + 1;
                tf = s*trials_per_session;
                avg_speed = mean(speed(map(ti:tf, :)));
                [~, ord] = sort(avg_speed);
                % discard N too stressed animals                
                idx = map(ti:tf, ord(length(ord) - nd + 1:end));
                groups(idx(:)) = -1;
            end
            id = id(ord(1:length(ord) - nd));
            map = map(:, ord(1:length(ord) - nd));

            animals_ids{1,1} = id;
            animals_trajectories_map{1,1} = map;
        else
            nd = an_b - an_a;
            if nd > 0
                nd = max(nd, 0);
            else
                nd = max(0 + nd, 0);
            end
            for s = 1:num_sessions                    
                ti = (s - 1)*trials_per_session + 1;
                tf = s*trials_per_session;
                avg_speed = mean(speed(map(ti:tf, :)));
                [~, ord] = sort(avg_speed);
                % discard N too calm animals                
                idx = map(ti:tf, ord(1:nd));                
                groups(idx(:)) = -2;                
            end
            id = id(ord(nd + 1:length(ord)));
            map = map(:, ord(nd + 1:length(ord)));  

            animals_ids{1,2} = id;
            animals_trajectories_map{1,2} = map;
        end    
    end   
end
