function results_full_classified_trajectories(segmentation_configs,classification_configs,output_dir,varargin)

    DEBUG = 0;
    
    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
    LineColor = [.2 .2 .2;...
                  .2 .2 .2;...
                  .2 .2 .2;...
                  .0 .6 .0;...
                  .0 .6 .0;...   
                  .0 .6 .0;...
                  .9 .0 .0;...
                  .9 .0 .0];
    LineStyle = {'-','--',':',':','--','-',':','-'};
    LineWidth = [1 1 1 1 1 1 1 1];

    all_trajectories = segmentation_configs.TRAJECTORIES;
    %all_segments = segmentation_configs.SEGMENTS;
    long_trajectories_map = find(long_trajectories(segmentation_configs) == 0); 
    %traj_lengths = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(:,10);
    [strat_distr,~,length_maps] = strats_distributions(segmentation_configs,classification_configs);
    all_trajectories.items(long_trajectories_map) = [];

    for i = 1:length(all_trajectories.items);

        points = all_trajectories.items(i).points;
        distr = strat_distr(i,:);
        part_length = 0; %total length covered by trajectory parts
        p = 2; %points of the trajectory
        len = norm(points(p, 2:3) - points(p-1, 2:3)); %total drawn trajectory
          
        % Generate a new figure
        f = figure;
        if ~DEBUG
            set(f,'Visible','off');
        end
        
        % Plot the arena
        plot_arena(segmentation_configs);
        hold on;
        
        % For every element in length_maps
        for j = 1:size(length_maps,2)
            if length_maps(i,j) == 0 % end of the trajectory
                break;
            end
            part_length = part_length + length_maps(i,j);
            % line specs
            if distr(j) > 0 
                lclr = LineColor(distr(j),:);
                lspc = LineStyle{distr(j)};
                w = 2.2 * LineWidth(distr(j));
            else
                lclr = [1 0 1]; %yellow
                lspc = '-';
                w = 1.5;
            end
            % start drawing
            while p <= size(points,1) && len < part_length
                plot(points(p-1:p,2), points(p-1:p,3) ,lspc,'LineWidth',w,'Color',lclr);
                len = len + norm(points(p, 2:3) - points(p-1, 2:3));   
                p = p + 1;
            end
        end
        
        % figure extra options, saving and closing
        set(gca,'LooseInset',[0,0,0,0]);
        set(gcf,'Color','w');
        if ~DEBUG
            export_figure(f, output_dir, sprintf('trajectory_%d', i), Export, ExportStyle);
        else
            pause(2);
        end
        close(f);   
    end
end
 