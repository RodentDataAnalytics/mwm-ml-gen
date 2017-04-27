function [varargout] = results_avg_strategies_trial(segmentation_configs,classification_configs,mfried_all,nanimals,output_dir)
   
    % Get number of trials
    trials_per_session = segmentation_configs.EXPERIMENT_PROPERTIES{30};
    ntrials = sum(trials_per_session);
    % Get classification
    segments_classification = classification_configs.CLASSIFICATION;
    
    p_table = []; %for storing the p-values
    tfried_all = cell(1,length(mfried_all));
    
    fn = fullfile(output_dir,'trial_strategies_p.txt');
    fileID = fopen(fn,'wt');
    
    for i = 1:length(mfried_all)
        mfried = mfried_all{i};
        tfried = [];
        for j = 1:nanimals;
            tmp1 = -1*ones(ntrials,1);
            tmp2 = -1*ones(ntrials,1);
            for t = 1:ntrials
                idx = nanimals*(t-1)+j;
                tmp1(t) = mfried(idx,1);
                tmp2(t) = mfried(idx,2);
            end
            tmp = [tmp1,tmp2];
            tfried = [tfried;tmp];
        end
        % Run friedman's test  
        p = -1;
        try
            p = friedman(tfried, ntrials, 'off');
            str = sprintf('Class: %s\tp_frdm: %g', segments_classification.classes{1,i}{1,2}, p);            
            fprintf(fileID,'%s\n',str);
            disp(str);
            p_table = [p_table;p];
        catch
            disp('Error on Friedman test. Friedman test is skipped');
            p_table = [p_table;p];
        end 
        tfried_all{1,i} = tfried;
    end
    
    fclose(fileID);
    varargout{1} = p_table;
    varargout{2} = tfried_all; % Friedman's test sample data
end
 