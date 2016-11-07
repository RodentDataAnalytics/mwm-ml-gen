function results_calibration(paths, varargin)
%Runs a series of calibration techniques (see calibrate_trajectory.m) and
%produces (for each technique) a graph showing the calibration error as a
%function of the number of calibration points.

%INPUT:
%{ trajectory_data_path, animal_groups_csv_path, cal_data_mat_path, output_path }

%OPTIONAL INPUT:
% varargin: number of calibration techniques 

    if ~isempty
        N = varargin{1,1};
    else
        N = 1;
    end
    
    path_data = paths{1,1};
    path_groups = paths{1,2};
    load(paths{1,3});
    path_output = paths{1,4};
    
    %path_data = 'C:\Users\Avgoustinos Vouros\Desktop\Paper\export';
    %path_output = 'C:\Users\Avgoustinos Vouros\Desktop\Paper\new results\segmentation';
    %path_groups = 'C:\Users\Avgoustinos Vouros\Desktop\Paper\new results\animal_groups.csv';
    %load('C:\Users\Avgoustinos Vouros\Desktop\Paper\export\_cal_data.mat'); 

    user_input = {{path_data,path_output,path_groups},{'rat','Time','X','Y'},{1,str2num('4,4,4'),3},{90,100,100,100,50,110,6,0,0},{250,0.7}};
    for i = 1:N
        try
            segmentation_configs_1 = config_segments(user_input,i);
            path_seg = check_cached_objects(segmentation_configs_1,3,i);
        catch
            fprintf('\n%d seg was skipped\n',i);
            continue;
        end
    end
    
    for i = 1:N
        try
            results_calibration_graphs(cal_data,2,i,path_output)
        catch
            fprintf('\n%d was skipped\n',i);
            continue;
        end        
    end    
end

