function trajectories_map_time_csv(my_trajectories,segmentation_configs,animals_trajectories_map,animals_ids,time_distr,dir_list)
%TRAJECTORIES_MAP_TIME_CSV 
%CSV header: 
% Animal ID, Trajectory ID, Trial No, 
% Original Group, Target Group, Time


    Tvars = {'AnimalID', 'TrajectoryID', 'TrialNo',...
        'OriginalGroup', 'TargetGroup', 'Time'};
    
    % Keep only the trajectories with length > 0
    long_trajectories_map = long_trajectories(segmentation_configs); 
    % Final animal groups
    groups = arrayfun( @(t) t.group, my_trajectories.items);
    sel_gr = [];
    for i = 1:length(animals_trajectories_map)
        t = animals_trajectories_map{i}(1);
        sel_gr = [sel_gr,t];
    end
    ng = length(sel_gr);
    % Original animal groups
    groups_o = arrayfun( @(t) t.group, segmentation_configs.SEGMENTS.parent.items);
    
    for i = 1:length(time_distr)
        table_v = [];
        table = {};
        tmp_time_distr = time_distr{i};
        for g = 1:ng
            map = animals_trajectories_map{g}; %Ntrials x Nanimals
            ids = animals_ids{g};
            for d = 1:length(ids) %number of animals
                for t = 1:size(map,1) %number of trials
                    tmp_v = [ids(d),map(t,d),t,groups_o(map(t,d)),groups(map(t,d))];
                    if long_trajectories_map(map(t,d)) == 0
                        tmp = -1;
                    else
                        tmp = tmp_time_distr(long_trajectories_map(map(t,d)),:);
                    end
                    table_v = [table_v;tmp_v];
                    table = [table;tmp];
                end
            end
        end
        tmp = num2cell(table_v);
        tmptmp = [tmp,table];
        T = cell2table(tmptmp,'VariableNames',Tvars);
        writetable(T,fullfile(dir_list{i},'RawData_time.csv'),'WriteVariableNames',1);
    end
end