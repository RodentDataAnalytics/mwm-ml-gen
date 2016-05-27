classdef trajectory < handle
    %TRAJECTORY Stores points of a trajectory or segment of trajectory 
    properties(GetAccess = 'public', SetAccess = 'public')
        points = [];
        % trajectory/segment identification
        session = -1;
        day = -1;
        trial = -1;
        track = -1;
        id = -1;
        group = -1;
        trial_type = -1;
        segment = -1;
        offset = -1;        
        start_time = -1;
        end_time = -1;
        start_index = -1;     
        traj_num = -1;
        tags = {};
    end

    methods
        % constructor
        function traj = trajectory(pts, session, track, group, id, trial, day, segment, off, starti, trial_type, traj_num)
            traj.points = pts;                       
            traj.session = session;
            traj.track = track;
            traj.start_index = starti;
            traj.group = group;
            traj.id = id;
            traj.trial = trial;
            assert(~isempty(segment));
            traj.segment = segment;
            traj.offset = off;            
            traj.day = day;                    
            traj.start_time = pts(1, 1);
            traj.end_time = pts(end, 1);
            traj.trial_type = trial_type;      
            traj.traj_num = traj_num;
        end
        
        % returns the full trajectory (or segment identification)
        function [ ident ] = identification(traj)
            ident = [traj.traj_num, traj.group, traj.session, traj.trial, traj.id];
        end
        
        function set_trial(inst, new_trial, trial_type)
            inst.trial = new_trial;
            inst.trial_type = trial_type;                      
        end
        
        function set_track(inst, new_track)
            inst.track = new_track;
        end
        
        function set_group(inst, new_group)
            inst.group = new_group;
        end
        
        % returns the data set and track number where the data originated
        function [ ident ] = data_identification(traj)
            ident = [traj.traj_num, traj.group, traj.session, traj.trial, traj.id];
        end                              
                        
        function [ segment ] = sub_segment(traj, beg, len)
            %SUB_SEGMENT returns a segment from the trajectory
            pts = [];
            dist = 0;
            starti = 0;
            for i = 2:size(traj.points, 1)
               dist = dist + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );
               if dist >= beg
                   if starti == 0
                       starti = i;
                   end
                   if dist > beg + len
                       % done we are
                       break;
                   end
                   % append point to segment
                   pts = [pts; traj.points(i, :)];
               end
            end 
            segment = trajectory(pts, traj.session, traj.track, traj.group, traj.id, traj.trial, traj.day, 0, traj.offset + beg, traj.start_index + starti - 1, traj.trial_type, traj_num);
        end  
        
         function [ segment ] = sub_segment_time(traj, toff, dt)
            %SUB_SEGMENT returns a segment from the trajectory
            pts = [];
            n = size(traj.points, 1);
            dist = 0;
            starti = 0;
            pts = [];
            if n > 0
                ti = traj.points(1, 1);
                for i = 2:n
                   dist = dist + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );
                   
                   if starti == 0
                       if traj.points(i, 1) - ti >= toff
                           starti = i;
                       end                     
                   else                 
                       if traj.points(i, 1) - traj.points(starti, 1) >= dt
                           break;
                       end
                   end
                end
                pts = traj.points(starti:i, :);
            end
            
            segment = trajectory(pts, traj.session, traj.track, traj.group, traj.id, traj.trial, traj.day, 0, traj.offset + beg, traj.start_index + starti - 1, traj.trial_type, traj_num);   
         end 
        
         function segs = partition(inst, func, varargin)
             segs = func(inst, varargin{:});
         end
        
        function pts = simplify(inst, tol)
            pts = trajectory_simplify_impl(inst.points, tol);
        end                               
    end 
end