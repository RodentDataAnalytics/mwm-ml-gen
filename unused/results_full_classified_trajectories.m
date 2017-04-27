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

    long_trajectories_map = find(long_trajectories(segmentation_configs) ~= 0); 
    [strat_distr,points] = distr_strategies_smoothing(segmentation_configs, classification_configs,varargin{:});

    for i = 1:20%size(strat_distr,2)
        f = figure;
        if ~DEBUG
            set(f,'Visible','off');
        end
        plot_arena(segmentation_configs);
        hold on;
        
        classed_traj = strat_distr(i,:);
        classed_points = points(i,:);
        endIndex = length(find(classed_traj ~= -1));
        for j = 1:endIndex%for each interval
            cp = classed_points{j};
            % line specs
            if classed_traj(j) > 0 
                lclr = LineColor(classed_traj(j),:);
                lspc = LineStyle{classed_traj(j)};
                w = 2.2 * LineWidth(classed_traj(j));
            else
                lclr = [1 0 1]; %yellow
                lspc = '-';
                w = 1.5;
            end            
            for p = 2:size(cp,1)%for each point of the interval
                plot(cp(p-1:p,2),cp(p-1:p,3),lspc,'LineWidth',w,'Color',lclr);
            end
        end
        set(gca,'LooseInset',[0,0,0,0]);
        set(gcf,'Color','w');  
        if ~DEBUG
            export_figure(f, output_dir, sprintf('trajectory_%d', long_trajectories_map(i)), Export, ExportStyle);
        end
        close(f);
    end
end
 