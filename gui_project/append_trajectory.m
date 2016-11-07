function [traj] = append_trajectory(traj,index,traj_num,group,data)
%APPEND_TRAJECTORY
    
    %Fixed variables
    trial_type = 1;
    segment = -1;
    off = -1;
    starti = 1;
    
    %Known variables
    %traj_num
    %group
    track = data{index,1};
    session = data{index,2};
    id = data{index,3};
    pts = data{index,5};
    
    %Unknown variables (fix later)  
    day = -1;
    trial = -1;

    %Create the trajectory object
    traj = traj.append(trajectory(pts, session, track, group, id, trial, day, segment, off, starti, trial_type, traj_num));
end

