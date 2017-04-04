function [w,max_w,Lk] = computed_weights_tiago(strat_distr,tags,ovl)
%COMPUTED_WEIGHTS_TIAGO computes adopted weights for minor and major classes
%w = final weights
%max_w = max weight
%Lk = 'true' continuous segments length (maximum or average)

%OPTION 1, Average #:
% #0. Lcon(traj),k -> a = max(Lcon(traj),k) -> b = max(a)
%     w = b/a

% #1. <Lcon(traj),k> -> a = <max(Lcon(traj),k)> -> b = max(a), where <no zeros>
%     w = b/a

% #2. <Lcon(traj),k> -> a = <max(Lcon(traj),k)> -> b = max(a), where <all>
%     w = b/a

%OPTION 2, Average #:
% Same as OPTION 1 but here take the average of continuous lengths

    % 1,2 only works
    OPTION = 1;
    AVERAGE = 0;

    continuous_lengths = zeros(size(strat_distr,1),length(tags));
    overall_lengths = zeros(size(strat_distr,1),length(tags));
    max_continuous_lengths = zeros(1,length(tags));
    max_overall_lengths = zeros(1,length(tags));
    avg_continuous_lengths = zeros(size(strat_distr,1),length(tags));
    avg_max_continuous_lengths = zeros(1,length(tags));
    for c = 1:length(tags)
        for i = 1:size(strat_distr,1)
            idx = find(strat_distr(i,:) == c);
            if isempty(idx)
                continue;
            end   
            endIndex = find(strat_distr(i,:) ~= -1);
            endIndex = length(endIndex)-1;
            tmp = strat_distr(i,:);
            tmp(idx) = -99;
         
            % get the max length of c strategy in i trajectory
            overall_lengths(i,c) = length(idx);
            
            % find the average max continuous length of c strategy in i trajectory
            count_vector = [];
            countv = 0;
            cvi = 1;
            for j = 1:endIndex
                if tmp(j) == -99
                    countv = countv + 1;
                elseif tmp(j) ~= -99
                    count_vector(cvi) = countv;
                    cvi = cvi + 1;
                    countv = 0;
                end
                if j == endIndex
                    count_vector(cvi) = countv;
                end
            end
            assert(sum(count_vector) == overall_lengths(i,c)); % sanity check
            a = find(count_vector ~= 0); %we cannot have []
            avg_continuous_lengths(i,c) = sum(count_vector) / length(a);

            % find the max continuous length of c strategy in i trajectory
            continuous_lengths(i,c) = max(count_vector);
        end
        % find the max continuous length of c strategy of all the trajectories
        max_overall_lengths(c) = max(max_overall_lengths(:,c));  
        % get the max length of c strategy of all the trajectories
        max_continuous_lengths(c) = max(continuous_lengths(:,c));
        % get the average max length of c strategy of all the trajectories
        avg_max_continuous_lengths(c) = max(avg_continuous_lengths(:,c));
    end

    switch OPTION
    case 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if AVERAGE == 1
            for i = 1:length(tags)
                a = length(find(continuous_lengths(:,i) > 0));
                max_continuous_lengths(i) = sum(continuous_lengths(:,i)) / a;
            end 
        end
        if AVERAGE == 2
            for i = 1:length(tags)
                max_continuous_lengths(i) = sum(continuous_lengths(:,i)) / size(continuous_lengths,1);
            end 
        end

        Lk = ones(1,length(tags));
        for i = 1:length(tags)
            Lk(i) = (max_continuous_lengths(i) - 1) * (1-ovl) + 1;
        end
        Lk_max = ones(1,length(tags));
        Lk_max = Lk_max .* max(Lk);  

        w = Lk_max ./ Lk;
        max_w = Lk_max(1);
    case 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if AVERAGE == 1
            for i = 1:length(tags)
                a = length(find(avg_continuous_lengths(:,i) > 0));
                avg_max_continuous_lengths(i) = sum(avg_continuous_lengths(:,i)) / a;
            end 
        end
        if AVERAGE == 2
            for i = 1:length(tags)
                avg_max_continuous_lengths(i) = sum(avg_continuous_lengths(:,i)) / size(avg_continuous_lengths,1);
            end 
        end

        Lk = ones(1,length(tags));
        for i = 1:length(tags)
            Lk(i) = (avg_max_continuous_lengths(i) - 1) * (1-ovl) + 1;
        end
        Lk_max = ones(1,length(tags));
        Lk_max = Lk_max .* max(Lk);  

        w = Lk_max ./ Lk;
        max_w = Lk_max(1);
    end
end
