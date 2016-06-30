function [ traj ] = set_data( path, data_files, data_user, properties, session, varargin )
%SET_DATA converts user's data to their final form for processing
    
    day = -1;
    traj = trajectories([]);
    
    ext = {'/*.csv','/*.CSV','/*.xlsx','/*.XLSX'};
    for i = 1:length(ext)
        files = dir(fullfile(path, ext{i}) );
        if ~isempty(files)
        	break
        end    
    end    
    
    fprintf('Importing %d trajectories...\n', length(files));
    str = ['Importing ',num2str(length(files)),' trajectories'];
    h = waitbar(0,str,'Name','Importing trajectories');

    for i = 1:length(files)
        data = parse_data(fullfile(path, files(i).name),...
                        data_files{1,1}{1,1}, data_files{1,2}{1,1},...
                        data_files{1,3}{1,1}, data_files{1,4}{1,1});
        
        %Check if we have the time,x,y -> if we don't the file is marked
        %Also check if we have id -> if we don't the file is dropped
        if ~isempty(data{1,1}) || data{1,3}==1;
            fprintf('Skipped: %s\n',fullfile(path, files(i).name));
            continue;
        end
        
        %If group is missing fix it with the user's data
        if ~isempty(data_user)
            group = find(data{1,2}==data_user{session,1});
            %In case the animal id does not exist in the file 
            if isempty(group)
                fprintf('Skipped: %s\n',fullfile(path, files(i).name));
                continue
            end    
            group = data_user{session,1}(group(1),2);
        %If no user's data are provided assume that all animals belong  
        %to group 1.    
        else
            group = 1;
        end 
        
        if ~isempty(varargin) % If the published data are required
            if isequal(varargin{1,1},'original_data')
                temp = sscanf(files(i).name,'day%d_%d');
                day = temp(1);
                load(varargin{1,2}); % loads 'calibration_data'
                pts = data{1,4};
                set = strfind(path,'set');
                set = set(end); % take last element
                index = sscanf(path(set+3),'%d'); % take the set number
                pts = calibrate_trajectory(pts,calibration_data{index});
                pts(:,2) = pts(:,2) - properties{1,4}{1,1};
                pts(:,3) = pts(:,3) - properties{1,6}{1,1};
                data{1,4} = pts;
                % Fix platform position
                temp_plat_x = properties{1,10}{1,1} - properties{1,4}{1,1};
                temp_plat_y = properties{1,12}{1,1} - properties{1,6}{1,1}; 
            end    
        else    
            % Move centre to 0,0
            pts = data{1,4};
            pts(:,2) = pts(:,2) - properties{1,4}{1,1};
            pts(:,3) = pts(:,3) - properties{1,6}{1,1};  
            % Flip if needed
            if properties{1,16}{1,1}
                pts(:,2) = -pts(:,2);
            end    
            if properties{1,18}{1,1} 
                pts(:,3) = -pts(:,3);
            end    
            data{1,4} = pts;  
            % Fix platform position
            temp_plat_x = properties{1,10}{1,1} - properties{1,4}{1,1};
            temp_plat_y = properties{1,12}{1,1} - properties{1,6}{1,1}; 
            % Flip if required
            if properties{1,16}{1,1}
                temp_plat_x = -temp_plat_x;
            end    
            if properties{1,18}{1,1} 
                temp_plat_y = -temp_plat_y;
            end             
        end
        
        %Chop points at the end on top of the platform            
        npts = size(data{1,4}, 1);
        cuti = npts;
        for k = 0:(size(data{1,4}, 1) - 1)
            if sqrt((data{1,4}(npts - k, 2) - temp_plat_x)^2 + (data{1,4}(npts - k, 3) - temp_plat_y)^2) > 1.5*properties{1,14}{1};
                break;
            end
            cuti = npts - k - 1;
        end
        
        %In case we have very few pts left take the full trajectory
        if cuti < length(data{1,4}) - (85*length(data{1,4}))/100
            cuti = length(data{1,4});
        end    
        data{1,4} = data{1,4}(1:cuti, :);
        
        %Append trajectory
        if size(data{1,4}, 1) > 0
            track = i;
            pts = data{1,4};
            id = data{1,2};
            trial = -1;
            segment = -1;
            off = -1;
            starti = 1;
            trial_type = 1;
            traj_num = i;
            traj = traj.append(trajectory(pts, session, track, group, id, trial, day, segment, off, starti, trial_type, traj_num));
        end 
        waitbar(i/length(files));
    end  
    close(h);
end

