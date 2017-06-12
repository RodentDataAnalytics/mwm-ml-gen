function all_p = friedman_test_results(p_mfried,p_mfriedAnimal, mfried_all,nanimals,mfriedAnimal_all,trials_per_session,classes,output_dir,varargin)
%FRIEDMAN_TEST_RESULTS
    
    ANIMALS = 1;
    TRIALS = 0;
    DAYS = 1;   
    METRICS = 0;

    for i = 1:length(varargin)
        if isequal(varargin{i},'ANIMALS')
            ANIMALS = varargin{i+1};
        elseif isequal(varargin{i},'TRIALS')
            TRIALS = varargin{i+1};
        elseif isequal(varargin{i},'DAYS')
            DAYS = varargin{i+1};
        elseif isequal(varargin{i},'ALL')
            ANIMALS = 1;
            TRIALS = 1;
            DAYS = 1;
        elseif isequal(varargin{i},'METRICS')
            METRICS = 1;
        end
    end

    all_p = {};    
    
    % Strategies / Metrics column
    if METRICS
        column = classes;
    else
        column = {};
        if isequal(classes,'Transitions')
            column = {classes};
        else
            for i = 1:length(mfried_all) - 1
                c = classes{1,i}{1,2};
                column = [column,c];
            end
            column{end+1} = 'Direct Finding';
        end
    end

    % Header row
    header = {};
    if ANIMALS == 1
        header = [header,'PtrialPanimal'];
        p_mfried = num2cell(p_mfried);
        all_p = [all_p,p_mfried];
    end
    if TRIALS == 1
        header = [header,'PanimalPtrial'];
        p_mfriedAnimal = num2cell(p_mfriedAnimal);
        all_p = [all_p,p_mfriedAnimal];
    end
    % Friedman over days
    switch DAYS
        case 0
        case 1
            header = [header,'Day PtrialPanimal'];
            p_days = [];
            for i = 1:length(mfried_all)
                ps = mfried_all{i};
                friedm = [];
                ini = 1;
                for tr = 1:length(trials_per_session)
                    fin = ini-1 + nanimals*trials_per_session(tr);
                    tmp_ps = ps(ini:fin,:);
                    ini = fin+1;
                    for a = 1:nanimals
                        tmp = zeros(1,size(ps,2));
                        for t = a:nanimals:nanimals*trials_per_session(tr)
                            tmp = tmp + tmp_ps(t,:);
                        end
                        friedm = [friedm;tmp];
                    end
                end
                try
                    p = friedman(friedm, nanimals, 'off');
                catch
                    p = -1;
                end
                p_days = [p_days;p];
            end
            p_days = num2cell(p_days);
            all_p = [all_p,p_days];
    end
    
    % Output
    T = [header;all_p];
    column = [' ',column];
    T = [column',T];
    Table = cell2table(T);
    writetable(Table,fullfile(output_dir,'Friedman_p.csv'),'WriteVariableNames',0);
end
