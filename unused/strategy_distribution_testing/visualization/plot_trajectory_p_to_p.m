%segmentation_configs;
length_maps = true_length_maps;
all_trajectories = segmentation_configs.TRAJECTORIES;

figure
hold on

for i = 1:length(all_trajectories.items);

    points = all_trajectories.items(i).points;
%    distr = strat_distr(i,:);
    part_length = 0; %total length covered by trajectory parts
    p = 2; %points of the trajectory
    len = norm(points(p, 2:3) - points(p-1, 2:3)); %total drawn trajectory

    % Generate a new figure
%     f = figure;
%     if ~DEBUG
%         set(f,'Visible','off');
%     end

    % Plot the arena
    plot_arena(segmentation_configs);
    hold on;

    % For every element in length_maps
    for j = 1:size(length_maps,2)
        if length_maps(i,j) == 0 % end of the trajectory
            break;
        end
        part_length = part_length + length_maps(i,j);
%         % line specs
%         if distr(j) > 0 
%             lclr = LineColor(distr(j),:);
%             lspc = LineStyle{distr(j)};
%             w = 2.2 * LineWidth(distr(j));
%         else
%             lclr = [1 0 1]; %yellow
%             lspc = '-';
%             w = 1.5;
%         end
        % start drawing
        while p <= size(points,1) && len < part_length
            plot(points(p-1:p,2), points(p-1:p,3) ,'k-','LineWidth',1.5);
            len = len + norm(points(p, 2:3) - points(p-1, 2:3));   
            p = p + 1;
        end
    end

    % figure extra options, saving and closing
    set(gca,'LooseInset',[0,0,0,0]);
    set(gcf,'Color','w');
%     if ~DEBUG
%         export_figure(f, output_dir, sprintf('trajectory_%d', i), Export, ExportStyle);
%     else
%         pause(2);
%     end
    %close(f);   
end
