function [ ids, map ] = published_animal_results(g,speed,ids,map)
%PUBLISHED_ANIMAL_RESULTS gets the exact same animals as the ones used
% to produce the published results (it is used to form the the animals_map)
    
    trials_per_session = [4,4,4];
    avg_speed = mean(speed(map));
    [~, ord] = sort(avg_speed);
    if g == 1
        nd = 0;
        for s = 1:3                    
            ti = (s - 1)*trials_per_session + 1;
            tf = s*trials_per_session;
            avg_speed = mean(speed(map(ti:tf, :)));
            [~, ord] = sort(avg_speed);
            % discard N too stressed animals                
            idx = map(ti:tf, ord(length(ord) - nd + 1:end));
            group(idx(:)) = -1;
        end
        ids = ids(ord(1:length(ord) - nd));
        map = map(:, ord(1:length(ord) - nd));
    else
        nd = 3;
        for s = 1:3                    
            ti = (s - 1)*trials_per_session + 1;
            tf = s*trials_per_session;
            avg_speed = mean(speed(map(ti:tf, :)));
            [~, ord] = sort(avg_speed);
            % discard N too calm animals                
            idx = map(ti:tf, ord(1:nd));                
            group(idx(:)) = -2;                
        end
        ids = ids(ord(nd + 1:length(ord)));
        map = map(:, ord(nd + 1:length(ord)));                    
    end
end

