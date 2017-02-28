line([1 100],[0 0],'LineStyle',LineStyle{1},'Color',LineColor(1,:),'LineWidth',2);
axis off
hold on
line([200 300],[0 0],'LineStyle',LineStyle{2},'Color',LineColor(2,:),'LineWidth',2);
line([1 100],[1 1],'LineStyle',LineStyle{3},'Color',LineColor(3,:),'LineWidth',2);
line([200 300],[1 1],'LineStyle',LineStyle{4},'Color',LineColor(4,:),'LineWidth',2);
line([1 100],[2 2],'LineStyle',LineStyle{5},'Color',LineColor(5,:),'LineWidth',2);
line([200 300],[2,2],'LineStyle',LineStyle{6},'Color',LineColor(6,:),'LineWidth',2);
line([1 100],[3 3],'LineStyle',LineStyle{7},'Color',LineColor(7,:),'LineWidth',2);
line([200 300],[3 3],'LineStyle',LineStyle{8},'Color',LineColor(8,:),'LineWidth',2);
set(gcf, 'Color', 'w');
hold off