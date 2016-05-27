function [ traj ] = set_data( path, data_files, data_user, properties, session, varargin )
%SET_DATA converts user's data to their final form for processing
    
    day = -1; % day if fixed afterwards
    traj = trajectories([]);
    files = dir(fullfile(path, '/*.csv') );
    fprintf('Importing %d trajectories...\n', length(files));
    
    skipped_files = cell(length(files),1);
    s = 1;
    for i = 1:length(files)
        data = parse_data(fullfile(path, files(i).name),...
                        data_files{1,1}{1,1}, data_files{1,2}{1,1}, data_files{1,3}{1,1},...
                        data_files{1,4}{1,1}, data_files{1,5}{1,1}, data_files{1,6}{1,1});
        
        %Check if we have the time,x,y -> if we don't the file is marked
        %Also check if we have id,trial -> if we don't the file is marked
        if data{1,5}==1 || isempty(data{1,2}) || isempty(data{1,4});
            skipped_files{s,1} = fullfile(path, files(i).name);
            s = s+1;
            continue;
        end
        
        %If group is missing fix it with the user's data
        if isempty(data{1,3}) && ~isempty(data_user);
            group = find(data{1,2}==data_user{session,1});
            data{1,3} = data_user{session,1}(group(1),2);
            %In case the animal id is still missing mark the file 
            if isempty(data{1,3})
                skipped_files{s,1} = fullfile(path, files(i).name);
                s = s+1;
                continue;
            end 
        %If group is missing and no user's data are provided assume
        %that all animals are in group 1.    
        elseif isempty(data{1,3}) && isempty(data_user); 
            data{1,3} = 1;
        end 
        
        % If the published data are required
        if ~isempty(varargin)
            if isequal(varargin{1,1},'original_data')
                temp = sscanf(files(i).name,'day%d_%d');
                day = temp(1);
                load(varargin{1,2}); % loads 'calibration_data'
                dx = -100;
                dy = -100;
                pts = data{1,6};
                set = strfind(path,'set');
                set = set(end); % take last element
                index = sscanf(path(set+3),'%d'); % take the set number
                pts = calibrate_trajectory(pts,calibration_data{index});
                pts(:, 2) = pts(:, 2) + dx;
                pts(:, 3) = pts(:, 3) + dy;
                data{1,6} = pts;
            end    
        end    
        
        %Chop points at the end on top of the platform            
        npts = size(data{1,6}, 1);
        cuti = npts;
        for k = 0:(size(data{1,6}, 1) - 1)
            if sqrt((data{1,6}(npts - k, 2) - properties{1,10}{1})^2 + (data{1,6}(npts - k, 3) - properties{1,12}{1})^2) > 1.5*properties{1,14}{1};
                break;
            end
            cuti = npts - k - 1;
        end
        
        %In case we have very few pts left take the full trajectory
        if cuti < length(data{1,6}) - (85*length(data{1,6}))/100
            cuti = length(data{1,6});
        end    
        data{1,6} = data{1,6}(1:cuti, :);
        
        %Append trajectory
        if size(data{1,6}, 1) > 0
            track = i;
            pts = data{1,6};
            group = data{1,3};
            id = data{1,2};
            trial = data{1,4};
            segment = -1;
            off = -1;
            starti = 1;
            trial_type = 1;
            traj_num = i;
            traj = traj.append(trajectory(pts, session, track, group, id, trial, day, segment, off, starti, trial_type, traj_num));
        end 
    end    
end

