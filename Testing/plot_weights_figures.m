%% Weights Figures
% subfigures titles
titles = {'seg 300 07','seg 250 07','seg 250 09','seg 200 07'};
% get abbreviations and form x-axis tick names
class_tags = classification_configs.CLASSIFICATION_TAGS;
t = cell(1,length(class_tags)+2);
t{1} = ' ';
for i = 1:length(class_tags)
    t{i+1} = class_tags{i}{1};
end
t{end} = ' ';

fig = figure('units','normalized','outerposition',[0 0 1 1]);
set(fig,'Visible','off');
for iter = 1:4
    % get the average weight
    [~,avg_w] = hard_bounds(wu(iter,:));
    % plot the average weight
    f = subplot(2,2,iter);
    plot([0,length(class_tags)+1],[avg_w,avg_w],'color','black','LineStyle','--','LineWidth',2.5);
    hold on
    % find the position of the max weight
    [~,pos] = max(wu(iter,:));
    % plot each class unbounded
    for i = 1:size(wu,2)
        b = bar(i,wu(iter,i));
        set(b,'FaceColor','white','LineWidth',1.5);
        % if this bar has max weight paint it red
        if wb(iter,i) ~= 1
            set(b,'FaceColor','black','LineWidth',0.5);
        end
        % if it is the bar with the max weight write it on top
        if i == pos
            text(i,wu(iter,i), num2str(wu(iter,i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize', FontSize, 'FontName', FontName, 'FontWeight', 'bold');
        end
        % if it is the bar with the min weight write it on top
        if wu(iter,i) == 1
            text(i,wu(iter,i), num2str(wu(iter,i),'%0.2f'),'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize', FontSize, 'FontName', FontName, 'FontWeight', 'bold');
        end
    end      
    % add title
    title(titles{iter}); 
    % correct the axis limits
    axis([0 length(class_tags)+1 0 round(max(max(wb)))+1]);
    % add tags & correct xticks
    faxis = findobj(f,'type','axes'); 
    xticks = [];
    for i = 1:length(class_tags)+2
        xticks = [xticks, i-1];
    end
    set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
    hold off
end
export_figure(fig, npath, 'class_weights', Export, ExportStyle);
close(fig);