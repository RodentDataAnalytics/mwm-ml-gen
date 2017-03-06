% Plot all the trajectories
output_dir = 'C:\Users\Avgoustinos\Desktop\New folder\trajectories';
[~, ~, ~, Export, ExportStyle] = parse_configs;
for i = 1:length(segmentation_configs.TRAJECTORIES.items)
    f = figure;
    set(f,'Visible','off');
    plot_arena(segmentation_configs);
    plot_trajectory(segmentation_configs.TRAJECTORIES.items(i))
    export_figure(f, output_dir, sprintf('trajectory_%d', i), Export, ExportStyle);
    close(f);
end

output_dir = 'C:\Users\Avgoustinos\Desktop\New folder\hard_bounds';
results_classified_trajectories(segmentation_configs,classification_configs,output_dir);

output_dir = 'C:\Users\Avgoustinos\Desktop\New folder\no_hard_bounds';
results_classified_trajectories(segmentation_configs,classification_configs,output_dir,'hard_bounds','off');
