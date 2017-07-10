function [ output_args ] = export_trajectory_pic(ppath,varargin)
%EXPORT_TRAJECTORY_PIC 

    FNAME = '';
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'FNAME')
            FNAME = varargin{i+1};
        end
    end

    ppath = char_project_path(ppath);
    % export format
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    % make a folder
    if isempty(FNAME)
        folder = fullfile(ppath,'results');
    else
        folder = fullfile(ppath,'results',FNAME);
    end
    if ~exist(folder,'dir')
        mkdir(folder);
    end
	% generate a new figure
    f = figure; 
    idx = get(f,'Number');
    set(f,'visible','off');
    
    h = waitbar(0,'Exporting...','Name','Results');
    
    
    % plot the arena
    plot_arena(segmentation_configs);
    % plot the trajectory
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(1,idx));  
    % export the figure
    export_figure(f, folder, strcat('traj',num2str(idx)), Export, ExportStyle);    
    figure(f);


end

