function results_classified_trajectories(segmentation_configs,classification_configs,output_dir,varargin)

    DEBUG = 0;
    output_dir = 'C:\Users\Avgoustinos\Desktop\New folder';

    LineColor = [.2 .2 .2;...
                 .2 .2 .2;...
                 .2 .2 .2;...
                 .0 .6 .0;...
                 .0 .6 .0;...   
                 .0 .6 .0;...
                 .9 .0 .0;...
                 .9 .0 .0];
    LineStyle = {'-','--',':',':','--','-',':','-'};
    LineWidth = [2 2 2 2 2 2 2 2];
    
    LineColor = [0 0 0;...
                 0 0 1;...
                 0 1 1;...
                 1 1 0;...
                 0 1 0;... %light green   
                 [12 195 82] ./ 255;... %green
                 [200 111 66] ./ 255;... %brown
                 1 0 0];
    LineStyle = {'-','-','-','-','-','-','-','-'};
    LineWidth = [2 2 2 2 2 2 2 2];

    % get the configurations from the configs file
    [~, ~, ~, Export, ExportStyle] = parse_configs;
    
    all_trajectories = segmentation_configs.TRAJECTORIES;
    %all_segments = segmentation_configs.SEGMENTS;
    %long_trajectories_map = long_trajectories( segmentation_configs ); 
    % Strategies distribution
    [~, ~, strat_distr] = distr_strategies_tiago(segmentation_configs, classification_configs, varargin{:});
    % Segments distribution
    [~, ~, segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
    % Minimum path interval
    %path_interval = segmentation_configs.SEGMENTATION_PROPERTIES;
    %path_interval = path_interval(1)*(1-path_interval(2));
      
    % User defined trajectories for plotting
    % default: all the trajectories that have segments
    itraj_start = 1;
    itraj_end = size(segments,1);   
    for i = 1:length(varargin)
        if isequal(varargin{i},'start')
            itraj_start = varargin{i+1};
        elseif isequal(varargin{i},'end')
            itraj_end = varargin{i+1};
        end
    end
    
    % Create a new figure and start plotting the trajectories, each one
    % point-to-point. After each trajectory clear the figure and continue.
    f = figure;
    if DEBUG == 0;
        set(f,'Visible','off');
    end
    for i = itraj_start:itraj_end
        endIndex = find(strat_distr(i,:) ~= -1); %find the last index
        endIndex = length(endIndex) - 1; %last is 0 (by implementation)
        traj_id = segments{i,1}.traj_num; %find the whole trajectory
        points = all_trajectories.items(traj_id).points; %get X, Y
        n_points = [];
for ii = 2:size(points,1)
    n = 10; %for example
    A(1) = points(ii-1,2);
    A(2) = points(ii-1,3);
    B(1) = points(ii,2);
    B(2) = points(ii,3);
    xy = [linspace(A(1),B(1),n); linspace(A(2),B(2),n)];
    for j = 1:size(xy,2)
        tmp = [xy(1,j),xy(2,j)];
        n_points = [n_points;tmp];
    end
end
points = [ones(size(n_points,1),1),n_points];
        traj_length = segmentation_configs.FEATURES_VALUES_TRAJECTORIES(traj_id,10); %get trajectory length
        seg_cov = traj_length/endIndex; %split the traj into equal lengths (length)
        % Plot the arena
        plot_arena(segmentation_configs);
        hold on;
        % Plot the trajectory point-to-point
        p = 2; %points of the trajectory
        len = norm(points(p, 2:3) - points(p-1, 2:3)); %total drawn trajectory
        for j = 1:endIndex
            % get line properties (color, style, width)
            if strat_distr(i,j) > 0
                lc = LineColor(strat_distr(i,j),:);
                ls = LineStyle{strat_distr(i,j)};
                lw = LineWidth(strat_distr(i,j));
            else
                lc = [1 0 1]; %magenta
                ls = '-'; %normal straight line
                lw = max(LineWidth)+0.5; %a little bolder than the rest
            end
            %plot each part point-to-point
            while p <= size(points,1) && len <= seg_cov
                plot(points(p-1:p,2), points(p-1:p,3), 'Color',lc,'LineStyle',ls,'LineWidth',lw);
                len = len + norm(points(p, 2:3) - points(p-1, 2:3));   
                p = p + 1;
            end
            try
                len = norm(points(p, 2:3) - points(p-1, 2:3));
            catch
                continue;
            end
        end
        hold off;
        set(gca,'LooseInset',[0,0,0,0]); %http://undocumentedmatlab.com/blog/axes-looseinset-property
        set(f,'Color','w');
        % export and clear figure
        if DEBUG == 0
            export_figure(f, output_dir, sprintf('trajectory_%d', traj_id), Export, ExportStyle);
        end
        clf(f);
    end        
end
    
    
    
        