function features = features_list
%% FEATURES_LIST contains a list of all the available features
% Format: {abbreviation, full_name, function,...
%          {arguments found in config.COMMON_PROPERTIES},{extra arguments}}

    %% MORRIS WATER MAZE FEATURES %%                
    % Features used in the classification process
    FEATURE_MEDIAN_RADIUS = {'r_12', 'Median radius', 'trajectory_radius',{'CENTRE_X','CENTRE_Y','ARENA_R'},{0,0}};%1
    FEATURE_IQR_RADIUS = {'r_iqr', 'IQR radius', 'trajectory_radius',{'CENTRE_X','CENTRE_Y','ARENA_R'},{0,1}};%2
    FEATURE_FOCUS = {'f', 'Focus', 'trajectory_focus',{'CENTRE_X','CENTRE_Y'},{0}};%3
    FEATURE_CENTRE_DISPLACEMENT = {'D_ctr', 'Centre displacement', 'trajectory_centre_displacement',{'CENTRE_X','CENTRE_Y','ARENA_R'},{0}};%4 
    FEATURE_CV_INNER_RADIUS = {'Ri_CV', 'Inner radius variation', 'trajectory_cv_inner_radius',{'CENTRE_X','CENTRE_Y','ARENA_R'}};%5
    FEATURE_PLATFORM_PROXIMITY = {'P_plat', 'Platform proximity', 'trajectory_time_within_radius',{'PLATFORM_X','PLATFORM_Y','PLATFORM_R'},{0}};%6
    FEATURE_BOUNDARY_ECCENTRICITY = {'ecc', 'Boundary eccentricity', 'trajectory_eccentricity'};%7
    FEATURE_LONGEST_LOOP = {'L_max', 'Longest loop', 'trajectory_longest_loop',{'LONGEST_LOOP_EXTENSION'},{40,4}};%8
    % Other features
    FEATURE_LATENCY = {'Lat', 'Latency', 'trajectory_latency'};
    FEATURE_LENGTH = {'L', 'Path length', 'trajectory_length',{},{0}};
    FEATURE_AVERAGE_SPEED = {'v_m', 'Average speed', 'trajectory_average_speed',{},{0,1}};

    %FEATURE_MEAN_ANGLE = {'ang0', 'Mean angle', 'trajectory_mean_angle'};
    %FEATURE_DENSITY = {'rho', 'Density', 'trajectory_density'};
    %FEATURE_ANGULAR_DISPERSION = {'d_ang', 'Angular dispersion', 'trajectory_angular_dispersion'};
    %FEATURE_VARIANCE_SPEED = {'v_var', 'Speed variance', 'trajectory_speed_vatrajectory_speed_varianceriance'};
    
    features = {FEATURE_MEDIAN_RADIUS,FEATURE_IQR_RADIUS,FEATURE_FOCUS,FEATURE_CENTRE_DISPLACEMENT,...
                FEATURE_CV_INNER_RADIUS,FEATURE_PLATFORM_PROXIMITY,FEATURE_BOUNDARY_ECCENTRICITY,FEATURE_LONGEST_LOOP,...
                FEATURE_LATENCY,FEATURE_LENGTH,FEATURE_AVERAGE_SPEED};

end    