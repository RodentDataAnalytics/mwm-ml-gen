function paper_fig_confidence_intervals(score,sample,class_tags,fpath,ii,ttitle)
    
    %fpath = fileparts(fpath);
    fpath = fullfile(fpath,sprintf('binomial_%d.txt', ii));
    fileID = fopen(fpath,'wt');
    
    f = figure;
    %set(f,'Visible','off');
    
    % get configurations
    %[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    FontName = 'Arial';
    FontSize = 12;
    LineWidth = 1.2;
    Export = '.jpg';
    ExportStyle = 'High Quality';
    
    % get abbreviations
    t = cell(1,length(class_tags)+2);
    t{1} = ' ';
    for i = 1:length(class_tags)
        t{i+1} = class_tags{i}{1};
    end
    t{end} = ' ';
    
    % plot the line
    plot([0,length(class_tags)+1],[0.5,0.5],'color','black','LineStyle','--','LineWidth',2);
    hold on
    for i = 1:length(class_tags)    
        %Binomial parameter estimates
        %phat: maximum likelihood estimate of the probability of success in
        %      a given binomial trial based on the number of successes, x, 
        %      observed in n independent trials ("correct" mean). 
        %pci: 95% confidence interval
        [phat, pci] = binofit(score(i),sample);
        
        m = pci(1) + (pci(2)-pci(1)) / 2; %mean
        l = pci(1) - m; %lower limit
        u = pci(2) - m; %upper limit
        
        %write to file
        str = sprintf('Class: %s\t95%% confidence interval: [%g %g]\t"correct" mean: %g', class_tags{i}{1}, pci(1), pci(2), phat); 
        fprintf(fileID,'%s\n',str);
        
        %plot as errorbar
        errorbar( i, m, l, u, 'black', 'Marker', 'none', 'LineStyle', '-', 'LineWidth', LineWidth);
        
        %fix lower, mid, upper points and also plot the "correct" mean
        %plot(i,m,'color','black','LineStyle','none','Marker','o','MarkerFaceColor','black');
        %plot(i,pci(1),'color','black','LineStyle','none','Marker','*','MarkerFaceColor','black');
        %plot(i,pci(2),'color','black','LineStyle','none','Marker','*','MarkerFaceColor','black');
        plot([i-0.2,i+0.2],[pci(1),pci(1)],'color','black','LineStyle','-','Marker','none','LineWidth', LineWidth+0.1);
        plot([i-0.2,i+0.2],[pci(2),pci(2)],'color','black','LineStyle','-','Marker','none','LineWidth', LineWidth+0.1);
        plot(i,phat,'color','red','LineStyle','none','Marker','square','MarkerFaceColor','none','MarkerEdgeColor','black','LineWidth',2);
    end
    fclose(fileID);
    % correct the axis limits
    axis([0 length(class_tags)+1 -0.05 1.05]);
    hold off
    % add tags
    faxis = findobj(f,'type','axes');
    xticks = [];
    for i = 1:length(class_tags)+2
        xticks = [xticks, i-1];
    end
    %t = {'','S1','S2','S3','S4','S5','S6','S7','S8','TR'};
    set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
    title(ttitle);
    % export
    fpath = fileparts(fpath);
    export_figure(f, fpath, sprintf('binomial_%d', ii), Export, ExportStyle);
    close(f);
end