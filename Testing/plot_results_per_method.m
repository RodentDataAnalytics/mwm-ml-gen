%% Different Approaches Figures: Per Methodology
% get abbreviations and form x-axis tick names
class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};
t = cell(1,length(class_tags)+2);
t{1} = ' ';
for i = 1:length(class_tags)
    t{i+1} = class_tags{i}{1};
end
t{end} = ' ';
% titles and subtitles
titles = {'seg 300 07','seg 250 07','seg 250 09','seg 200 07'};
subtitles = {'Default','W=Unbounded','W=Ones','Class Results'};
s_names = {'seg_300_07','seg_250_07','seg_250_09','seg_200_07'};

for z = 1:length(titles)
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(fig,'Visible','off');
    %title(titles{z}); 
    for iter = 1:4
        f = subplot(2,2,iter);
        % Friedman test threshold (0.05)
        plot([0,length(class_tags)+1],[0.05,0.05],'color','black','LineStyle','--','LineWidth',1.5);
        hold on
        % plot each class
        for i = 1:size(store{1},1)
            b = bar(i,store{iter}(i,z));
            set(b,'FaceColor','black','LineWidth',0.5);
            if store{iter}(i,z) < 0.05
                set(b,'FaceColor','white','LineWidth',1.5);
            end
        end
        % add title
        title(subtitles{iter}); 
        % correct the axis limits
        axis([0 length(class_tags)+1 0 0.15]);
        % add tags & correct xticks
        faxis = findobj(f,'type','axes'); 
        xticks = [];
        for i = 1:length(class_tags)+2
            xticks = [xticks, i-1];
        end
        set(faxis, 'XTick', xticks, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
        hold off
    end
    export_figure(fig, npath, sprintf('per_method_%s',s_names{z}), Export, ExportStyle);
    close(fig);
end