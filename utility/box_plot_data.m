function box_plot_data(vals, groups, output_dir)
%BOX_PLOT_DATA extracts the values used to form the boxplot and exports
%them to a CSV file

    % for each strategy
    for i = 1:length(vals)
        bars = {};
        nums = unique(groups{i});
        % output file path and name
        fpath = fullfile(output_dir,strcat(strcat('segment_length_strategy_',num2str(i),'.csv')));
        % for each bar
        for j = 1:length(nums)
            bar = vals{i}(groups{i} == nums(j));
            bar = num2cell(bar); 
            % make the bar or the bars cell array bigger if needed
            if j ~= 1
                if length(bar) < size(bars,1)
                    bar{1,size(bars,1)} = [];
                elseif length(bar) > size(bars,1)
                    bars{length(bar),1} = [];
                end
            end
            % append
            bars = [bars,bar'];
        end
        % form and export bars table
        header = {};
        for h = 1:size(bars,2)
            str = strcat('bar',num2str(h));
            header = [header,str];
        end
        bars = [header;bars];
        table = cell2table(bars);
        writetable(table,fpath,'WriteVariableNames',0);
    end
end

