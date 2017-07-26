function create_average_figure_per(animals_trajectories_map,data,output_dir,total_trials,tags)
%CREATE_AVERAGE_FIGURE_PER generates one figure for each strategy that
%illustrates the average percentage of segments that fall under each  
%strategy throughout the trials.
    
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    iter = length(tags)+1;
    
    maxv = 0;
    avg_all = cell(1,iter);
    for t = 1:iter
        tmp = data{1}{t};
        for i = 2:length(data)
            tmp = tmp + data{i}{t};
        end
        avg = tmp./length(data);
        tmp = max(avg);
        if tmp > maxv
            maxv = tmp;
            extra = 5*maxv / 100;
        end
        avg_all{t} = avg;
    end
    
    %% Create and export the figures
    if length(animals_trajectories_map) == 1
        g = 1;
    else
        g = 2;
    end    
    for c = 1:length(avg_all)
        f = figure;
        set(f,'Visible','off');
        tmp = avg_all{c};
        if g == 1
            ba = bar(tmp, 'LineWidth',1.5);
            set(ba(1),'FaceColor','black');
        else
            tmp = reshape(tmp,[2,length(tmp)/2]);
            ba = bar(tmp', 'LineWidth',1.5);
            set(ba(1),'FaceColor','white');
            set(ba(2),'FaceColor','black');
        end

        %Axes
        faxis = findobj(f,'type','axes');
        set(faxis, 'Xlim', [0, total_trials+0.5], 'Ylim', [0, maxv+extra], 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);   
        if c < length(avg_all)
            title(tags{c}{2}, 'FontSize', FontSize, 'FontName', FontName);
        else
            title('Direct Finding', 'FontSize', FontSize, 'FontName', FontName);
        end
        xlabel('trials', 'FontSize', FontSize, 'FontName', FontName);  
        ylabel('average %', 'FontSize', FontSize, 'FontName', FontName); 

        %Overall
        set(f, 'Color', 'w');
        box off;  
        set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        %Export and delete
        export_figure(f, output_dir, sprintf('animal_strategy_per_%d', c), Export, ExportStyle);
        delete(f) 
    end    
    
    %% Export figures data
    bar_plot_data(avg_all,output_dir);
        
end