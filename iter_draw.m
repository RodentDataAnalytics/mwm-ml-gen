interval = [50,100,150,200];
sigma = [50,100,150,200];
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data\results\draw_test';
for i = 1:length(interval)
    for j = 1:length(sigma)
        fname = strcat('i',num2str(interval(i)),'s',num2str(sigma(j)));
        fpath = fullfile(output_dir,fname);
        mkdir(fpath);
        results_full_classified_trajectories(segmentation_configs,classification_configs,fpath,'INTERVAL',interval(i),'SIGMA',sigma(j));
    end
end
