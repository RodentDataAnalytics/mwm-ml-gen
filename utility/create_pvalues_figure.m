function error = create_pvalues_figure(table,class_tags,output_dir,varargin)
%CREATE_PVALUES_FIGURE creates a boxplot of the p-values.

    %remove DF
    if length(table{1,1}) > 1
        for i = 1:length(table)
            table{1,i}(end) = [];
        end
    end

    error = 1;
    TRIAL = 0;
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % default labels
    t = cell(1,length(class_tags));
    for i = 1:length(t)
        t{i} = class_tags{i}{1};
    end
    xlabel_ = 'strategies';
    ylabel_ = 'p-value';
    % get other options
    for i = 1:length(varargin)
        if isequal(varargin{i},'tag')
            t = varargin{i+1};
        elseif isequal(varargin{i},'xlabel')
            xlabel_ = varargin{i+1};
        elseif isequal(varargin{i},'ylabel')
            ylabel_ = varargin{i+1};
        elseif isequal(varargin{i},'trial')
            TRIAL = varargin{i+1};
        end
    end
    % convert to double array and find the mean of the rows
    table_ = cell2mat(table);
    table_ = table_';
    
    %% Generate the overall plot
    f = figure;
    set(f,'Visible','off');

    % plot boxplot
    boxplot(table_);
    hold on
    faxis = findobj(f,'type','axes');
    
    h = findobj(faxis,'Tag','Box');
    for j=1:length(h)
         patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
    end
    set(h, 'LineWidth', LineWidth);
    h = findobj(faxis, 'Tag', 'Median');
    for j=1:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', LineWidth);
    end
    h = findobj(faxis, 'Tag', 'Outliers');
    for j=1:length(h)
        set(h(j), 'MarkerEdgeColor', [0 0 0]);
    end   
    
    xlim([0 size(table_,2)+1]);
    ylim([0 1]); %friedman test cannot be more than 1
    xlabel(xlabel_, 'FontSize', FontSize);
    ylabel(ylabel_, 'FontSize', FontSize)
    set(faxis, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
    set(faxis, 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);
   
    box off; 
    set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
    % plot line
    y = 0.05;
    x1 = 0;
    x2 = size(table_,2);
    plot([x1,x2],[y,y],'color','red','LineStyle',':','LineWidth',1);
    hold off
    
    %export
    if TRIAL
        export_figure(f, output_dir, 'pvalues_trial_summary', Export, ExportStyle);
    else
        export_figure(f, output_dir, 'pvalues_summary', Export, ExportStyle);
    end
    close(f);
    
    %% Generate the focused plot
    f = figure;
    set(f,'Visible','off');
    
    % plot boxplot
    boxplot(table_);
    hold on
    faxis = findobj(f,'type','axes');
    
    h = findobj(faxis,'Tag','Box');
    for j=1:length(h)
         patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
    end
    set(h, 'LineWidth', LineWidth);
    h = findobj(faxis, 'Tag', 'Median');
    for j=1:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', LineWidth);
    end
    h = findobj(faxis, 'Tag', 'Outliers');
    for j=1:length(h)
        set(h(j), 'MarkerEdgeColor', [0 0 0]);
    end   
    
    xlim([0 size(table_,2)+1]);
    ylim([0 0.1]);
    xlabel(xlabel_, 'FontSize', FontSize);
    ylabel(ylabel_, 'FontSize', FontSize)
    set(faxis, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
    set(faxis, 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);
   
    box off; 
    set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
    % plot line
    y = 0.05;
    x1 = 0;
    x2 = size(table_,2);
    plot([x1,x2],[y,y],'color','red','LineStyle',':','LineWidth',1);
    hold off
    
    %export
    if TRIAL
        export_figure(f, output_dir, 'pvalues_trial_summary_focus', Export, ExportStyle);
    else
        export_figure(f, output_dir, 'pvalues_summary_focus', Export, ExportStyle);
    end
    close(f);
    
    error = 0;
end

