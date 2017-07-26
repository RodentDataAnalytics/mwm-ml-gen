function [seg_points,distances,rem_points,rem_distances] = detailed_trajectory_segmentation(trajectory_points, trajectory_length, varargin)

    custom_length = 50; %length of each segment
    times = 20; %number of iterations for correction
    safe = 0; %error margin
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'length')
            custom_length = varargin{i+1};
        elseif isequal(varargin{i},'iterations')
            times = varargin{i+1};
        elseif isequal(varargin{i},'safety')
            safe = varargin{i+1};
        end
    end
            
    seg_points = {}; %stores the coordinates of each segment [Time,X,Y]
    seg_lengths = []; %stores the length of each segment
    seg_offsets = []; %stores the offset of each segment

    cov = 0; %temp coverage used along with custom_length
    coverage = 0; %true, overall coverage
    a = trajectory_points;
    s = size(a,1); %total number of trajectory points
    i = 2; %points index
    k = 1; %keeps track of i
    while coverage < intmax
        d = norm(a(i,2:3) - a(i-1,2:3)); %compute distance between the 2 points
        %update the temp and true coverage
        cov = cov + d;
        coverage = coverage + d;
        %check if temp coverage have exceeded the custom_length
        if cov > custom_length
            m = cov - custom_length;
            %previous coordinates
            x_prev = a(i-1,2);
            y_prev = a(i-1,3);
            %current coordinates
            x_now = a(i,2);
            y_now = a(i,3);
            %correction loop
            for j = 1:times
                %get the middle point and compute the new distance
                x1 = linspace(x_prev,x_now,3);
                y1 = linspace(y_prev,y_now,3);
                new_d = norm([x1(2),y1(2)] - a(i-1,2:3));
                %check if we are within the margin
                if abs(m-new_d) < safe
                    break;
                else
                    if new_d < m
                        %move to the second half and re-split
                        x_prev = x1(2);
                        y_prev = y1(2);
                    elseif new_d > m
                        %move to the first half and re-split
                        x_now = x1(2);
                        y_now = y1(2);
                    end
                end
            end
            new_point = [-1,x1(2),y1(2)];
            a = [ a(1:i-1,:) ; new_point ; a(i:end,:) ];  
            s = s+1;
            new_d = norm(new_point(1,2:3) - a(i-1,2:3));
            %update the temp and the true coverage
            coverage = coverage - d + new_d; 
            cov = cov - d + new_d;
            %update the arrays
            seg_lengths = [seg_lengths ; cov];
            seg_points{end+1} = [a(k:i-1,:);new_point];
            seg_offsets = [seg_offsets ; coverage-cov];
            %set temp coverage to 0
            cov = 0;  
            k = i;
        end    
        i = i+1;
        if i > s
            %store the remaining points as a new segment
            rem_length = cov;
            rem_points = a(k:i-1,:);
            rem_offsets = coverage-cov;
            break;
        end
    end
    %package output
    distances = [seg_lengths,seg_offsets];
    rem_distances = [rem_length,rem_offsets];
    %DEBUG:
    error_min = find(distances(:,1) < custom_length);
    error_max = find(distances(:,1) > custom_length);
    error_mean = mean(distances(:,1));
    %max(distances(:,1))
    %min(distances(:,1))
end
