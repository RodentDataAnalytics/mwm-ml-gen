function results_classified_trajectories(segmentation_configs,classification_configs,output_dir,varargin)

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
    all_segments = segmentation_configs.SEGMENTS;
    long_trajectories_map = long_trajectories( segmentation_configs ); 
    [strat_distr,~] = strats_distributions(segmentation_configs,classification_configs);
    %[strat_distr, ~, ~, ~] = distr_strategies(segmentation_configs, classification_configs, varargin);

    for i = 1:length(all_trajectories.items);
        if long_trajectories_map(i) == 0 % segmentation_configs.partision(i)==0
            continue;
        end
        nseg = segmentation_configs.PARTITION(i);
        seg0 = 1;

        % Find the first segment No. of the trajectory
        if i > 1
            s = cumsum(segmentation_configs.PARTITION);
            seg0 = s(i-1);
        end

        distr = strat_distr(long_trajectories_map(i),:);
        %vals = classification_configs.CLASSIFICATION.class_map(seg0 : seg0 + nseg);

        % Plot classified trajectory
        f = figure;
        set(f,'Visible','off');
        plot_arena(segmentation_configs);
        hold on;

        lastc = distr(1);
        lasti = 1;
        for j = 2:nseg
            if j == nseg
                lastc = distr(j);
                starti = all_segments.items(seg0 + lasti).start_index;
                if distr(j-1) > 0 
                    lclr = LineColor(distr(j-1),:);
                    lspc = LineStyle{distr(j-1)};
                    w = 2.2 * LineWidth(distr(j-1));
                else
                    lclr = [1 0 1]; %yellow
                    lspc = '-';
                    w = 1.5;
                end
                plot(all_trajectories.items(i).points(starti:end,2),all_trajectories.items(i).points(starti:end,3),lspc,'LineWidth',w,'Color',lclr);
                plot(all_trajectories.items(i).points(starti,2),all_trajectories.items(i).points(starti,3),'r*', 'LineWidth', 2);
                plot(all_trajectories.items(i).points(end,2),all_trajectories.items(i).points(end,3),'rx', 'LineWidth', 2);
                lasti = j;
            elseif distr(j) ~= lastc
                lastc = distr(j);
                starti = all_segments.items(seg0 + lasti).start_index;
                endi = all_segments.items(seg0 + j).start_index;
                if distr(j-1) > 0 
                    lclr = LineColor(distr(j-1),:);
                    lspc = LineStyle{distr(j-1)};
                    w = 2.2 * LineWidth(distr(j-1));
                else
                    lclr = [1 0 1]; %yellow
                    lspc = '-';
                    w = 1.5;
                end
                plot(all_trajectories.items(i).points(starti:endi,2),all_trajectories.items(i).points(starti:endi,3),lspc,'LineWidth',w,'Color',lclr);
                plot(all_trajectories.items(i).points(starti,2),all_trajectories.items(i).points(starti,3),'r*', 'LineWidth', 2);
                plot(all_trajectories.items(i).points(endi,2),all_trajectories.items(i).points(endi,3),'rx', 'LineWidth', 2);
                lasti = j;
            end
        end
        %set(gca,'LooseInset',[0,0,0,0]);
        %set(gcf,'Color','w');
        
        export_figure(f, output_dir, sprintf('trajectory_%d', i), Export, ExportStyle);
        close(f);
    end
end
    
    
    
        