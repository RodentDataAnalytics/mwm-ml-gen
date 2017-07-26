function results_full_classified_trajectories(segmentation_configs,classification_configs,output_dir,varargin)

    DEBUG = 0;
    WAITBAR = 1;
    CUSTOM = 2;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'CUSTOM')
            CUSTOM = varargin{i+1};
        elseif isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        end
    end
    
    % get the configurations from the configs file
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
    switch CUSTOM
        case 1
            LineColor = [.2 .2 .2;...
                          .2 .2 .2;...
                          .2 .2 .2;...
                          .0 .6 .0;...
                          .0 .6 .0;...   
                          .0 .6 .0;...
                          .9 .0 .0;...
                          .9 .0 .0];
            LineStyle = {'-','--',':',':','--','-',':','-'};
        otherwise
            LineColor = [0 0 0;...
                          1 1 0;...
                          1 0 1;...
                          0 1 1;...
                          0 1 0;...   
                          0 0 1;...
                          .8 .8 .8;...
                          1 0 0];
            LineStyle = {'-','-','-','-','-','-','-','-'};    
            LineWidth = [1 1 1 1 1 1 1 1];
    end

    long_trajectories_map = find(long_trajectories(segmentation_configs) ~= 0); 
    [strat_distr,points,points_extra] = distr_strategies_smoothing(segmentation_configs, classification_configs,varargin{:});

    if DEBUG
        ending = 20;
    else
        ending = size(strat_distr,1);
    end
    
    if WAITBAR
        h = waitbar(0,'Generating results...','Name','Results');
    end
    
    parfor i = 1:ending
        f = figure;
        if ~DEBUG
            set(f,'Visible','off');
        end
        plot_arena(segmentation_configs);
        hold on;
        
        classed_traj = strat_distr(i,:);
        classed_points = points(i,:);
        endIndex = length(find(classed_traj ~= -1));
        %add also the remainng points at the end
        classed_points{endIndex} = [classed_points{endIndex};points_extra{i}];
        for j = 1:endIndex%for each interval
            cp = classed_points{j};
            % line specs
            if classed_traj(j) > 0 
                lclr = LineColor(classed_traj(j),:);
                lspc = LineStyle{classed_traj(j)};
                w = 2.2 * LineWidth(classed_traj(j));
            else
                lclr = [0 0 0]; %white
                lspc = '--';
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
        delete(f);
        if WAITBAR
            waitbar(i/ending); 
        end
    end
    
    %lines
    f = figure;
    if ~DEBUG
        set(f,'Visible','off');
    end    
    hold on
    s = [1 100 ; 200 300];
    p = 3;
    iter = 2;
    for i = 1:size(LineColor,1)
        if iter == 0
            iter = 2;
            p = p - 1;
        end
        if mod(i,2) == 0 %even
            tmp_s = s(2,:);
        else
            tmp_s = s(1,:);
        end
        line([tmp_s(1) tmp_s(2)],[p p],'LineStyle',LineStyle{i},'Color',LineColor(i,:),'LineWidth',2);
        axis off
        iter = iter - 1;
    end
    set(gcf, 'Color', 'w');
    l = legend('Thigmotaxis','Incursion','Scanning','Focused','Chaining','Self-oriented','S.Surroundings','S.Target');
    set(l,'Location','eastoutside','FontSize',14);
    hold off
    if ~DEBUG
        export_figure(f, output_dir,'legend', Export, ExportStyle);
    end   
    delete(f);
    
    %% Do also the full trajectories
    if ~DEBUG
        other_trajectories_map = find(long_trajectories(segmentation_configs) == 0); 
        for i = 1:length(other_trajectories_map)
            f = figure;
            set(f,'Visible','off');
            plot_arena(segmentation_configs);
            hold on;     
            plot_trajectory(segmentation_configs.TRAJECTORIES.items(other_trajectories_map(i)));
            export_figure(f, output_dir, sprintf('trajectory_%d', other_trajectories_map(i)), Export, ExportStyle);
            delete(f);
        end
    end
    
    if WAITBAR
        delete(h);
    end
end
 