function bar_plot_data(data, output_dir, varargin)

    for i = 1:length(data)
        header = {};
        for h = 1:size(data{i},2)
            str = strcat('bar',num2str(h));
            header = [header,str];
        end  
        bars = num2cell(data{i});
        bars = [header;bars];
        table = cell2table(bars);
        fpath = fullfile(output_dir,strcat('animal_strategy_per_',num2str(i),'.csv'));
        writetable(table,fpath,'WriteVariableNames',0);
    end
end
        