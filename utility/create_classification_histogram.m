function create_classification_histogram(class_map,strats,rpath,fname)
%CREATE_CLASSIFICATION_HISTOGRAM creates the histogram of the
%classification. Each bar represents one class and shows the number of
%data assigned to that class.
    
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
    % get abbreviations
    t = cell(1,length(strats));
    for i = 1:length(strats)
        t{i} = strats{i}{1};
    end
    
    % create a figure and make it invisible
    f = figure;
    set(f,'Visible','off');
    
    % Make a histogram with percentages on top of each bar
    h = histogram(class_map); %first run the histogram
    NumBins = get(h,'NumBins'); %get the number of bins (different classes)
    %centers: indicates the location of each bin center on the x-axis
    [points,centers] = hist(class_map,NumBins); 
    perc = 100 * points / sum(points); %compute percentage
    %using the centers plot bars
    b = bar(centers,points,'FaceColor',[0.4 0.4 0.4],'LineWidth',LineWidth);
    %create text above each bar 
    for i = 1:length(centers)
        if perc(i) ~= 0
            text(centers(i),points(i),[sprintf('%.1f',(perc(i))) '%'],...
                'HorizontalAlignment','center',...
                'VerticalAlignment','bottom',...
                'FontSize',FontSize,'FontName',FontName);
        end
    end 
    
    % correct the axis limits
    axis([0 length(strats)-1 0 max(points)+(10*max(points)/100)]);
    % add tags & correct xticks
    faxis = findobj(f,'type','axes');
    xticks = [];
    for i = 1:length(centers)
        xticks = [xticks, centers(i)];
    end
    set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
    
    % fix figure overview
    set(f, 'Color', 'w');
    box off;  
    set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    
    % export and close the figure
    export_figure(f, rpath, fname, Export, ExportStyle); 
    close(f);
end

