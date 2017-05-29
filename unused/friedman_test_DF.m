function [ p_table,data,groups,pos ] = friedman_test_DF(total_trials,animals_trajectories_map,long_trajectories_map,nanimals,p_table,fileID)
%FRIEDMAN_TEST_DF computes the Friedman test for the trajectories without
%segments

    mfried = zeros(nanimals*total_trials, 2);
    data = [];
    groups = [];
    pos = [];
    d = 0.05;
    grp = 1;
     
    for t = 1:total_trials
        for g = 1:2            
            map = animals_trajectories_map{g};
            pts = [];
            for i = 1:nanimals
                if long_trajectories_map(map(t, i)) == 0     
                    pts = [pts, 1];
                    mfried((t - 1)*nanimals + i, g) = 1;
                end                                           
            end
            if isempty(pts)
                data = [data, 0];
                groups = [groups, grp];
            else
                data = [data, pts];
                groups = [groups, ones(1, length(pts))*grp];
            end
            grp = grp + 1;
            pos = [pos, d];
            d = d + 0.05;                 
        end     
        if rem(t, 4) == 0
            d = d + 0.07;                
        end                
        d = d + 0.02;                
    end
    
    p = -1;
    try
        p = friedman(mfried, nanimals, 'off');
        str = sprintf('Class: unsegmented\tp_frdm: %g', p);            
        fprintf(fileID,'%s\n',str);
        disp(str);
        p_table = [p_table;p];
    catch
        disp('Error on Friedman test. Friedman test is skipped');
        p_table = [p_table;p];
    end  
end

