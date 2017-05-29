function box_plot_data(nanimals, vals, groups, output_dir, varargin)
%BOX_PLOT_DATA extracts the values used to form the boxplot and exports
%them to a CSV file

    % for each strategy
    if iscell(vals)
        for i = 1:length(vals)
            nums = unique(groups{i});
            bars = zeros(nanimals,length(nums));
            % output file path and name
            if length(vals) == 1
                fpath = fullfile(output_dir,'transitions.csv');
            else
                fpath = fullfile(output_dir,strcat('animal_strategy_',num2str(i),'.csv'));
            end
            % for each bar
            for j = 1:length(nums)
                bar = vals{i}(groups{i} == nums(j));
                for k = 1:length(bar)
                    bars(k,j) = bar(k);
                end
            end
            % form and export bars table
            header = {};
            for h = 1:size(bars,2)
                str = strcat('bar',num2str(h));
                header = [header,str];
            end
            bars = num2cell(bars);
            bars = [header;bars];
            table = cell2table(bars);
            writetable(table,fpath,'WriteVariableNames',0);
        end
    else
        nums = unique(groups);
        bars = zeros(nanimals,length(nums));
        if isempty(varargin)
            name = 'res1';
        else
            name = varargin{1};
        end
        % output file path and name
        fpath = fullfile(output_dir,strcat(strcat(name,'.csv')));
        % for each bar
        for j = 1:length(nums)
            bar = vals(groups == nums(j));
            for k = 1:length(bar)
                bars(k,j) = bar(k);
            end
        end
        % form and export bars table
        header = {};
        for h = 1:size(bars,2)
            str = strcat('bar',num2str(h));
            header = [header,str];
        end
        bars = num2cell(bars);
        bars = [header;bars];
        table = cell2table(bars);
        writetable(table,fpath,'WriteVariableNames',0);     
    end
end

