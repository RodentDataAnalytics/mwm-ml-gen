classdef trajectory < handle
    %TRAJECTORY Stores points of a trajectory or segment of trajectory 
    properties(GetAccess = 'public', SetAccess = 'public')
        points = [];
        % trajectory/segment identification
        set = -1;
        track = -1;
        group = -1;
        id = -1;
        trial = -1;
        trial_type = -1;
        segment = -1;
        offset = -1;        
        session = -1;
        start_time = -1;
        end_time = -1;
        start_index = -1;        
        tags = {};
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')        
        feat_val_ = [];    
        hash_ = -1;
    end

    methods
        % constructor
        function traj = trajectory(pts, set, track, group, id, trial, session, segment, off, starti, trial_type)
            traj.points = pts;                       
            traj.set = set;
            traj.track = track;
            traj.start_index = starti;
            traj.group = group;
            traj.id = id;
            traj.trial = trial;
            assert(~isempty(segment));
            traj.segment = segment;
            traj.offset = off;            
            traj.session = session;                    
            traj.start_time = pts(1, 1);
            traj.end_time = pts(end, 1);
            traj.trial_type = trial_type;            
        end
        
        % returns the full trajectory (or segment identification)
        function [ ident ] = identification(traj)
            ident = [traj.group, traj.id, traj.trial, traj.segment];
        end
        
        function set_trial(inst, new_trial, trial_type)
            inst.trial = new_trial;
            inst.hash_ = -1;
            inst.trial_type = trial_type;                      
        end
        
        function set_track(inst, new_track)
            inst.track = new_track;
            inst.hash_ = -1;
        end
        
        function set_group(inst, new_group)
            inst.group = new_group;
            inst.hash_ = -1;
        end
        
        function cache_feature_value(inst, hash, val)
            if isempty(inst.feat_val_)
                inst.feat_val_ = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
            end                   
            inst.feat_val_(hash) = val;            
        end
        
        function ret = has_feature_value(inst, feat)
            ret = ~isempty(inst.feat_val_) && inst.feat_val_.isKey(feat);
        end
        
        function out = hash_value(traj)       
            if traj.hash_ == -1                                          
                % compute hash
                len = 0;
                if traj.offset ~= -1
                    % length taken only into account when offset is used
                    len = true_len;
                end
                traj.hash_ = trajectory.compute_hash(traj.set, traj.session, traj.track, traj.offset, len);
            end
            out = traj.hash_;
        end
        
        % returns the data set and track number where the data originated
        function [ ident ] = data_identification(traj)
            ident = [traj.set, traj.session, traj.track];
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
             
            segment = trajectory(pts, traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, 0, traj.offset + beg, traj.start_index + starti - 1, traj.trial_type);   
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
            
            segment = trajectory(pts, traj.set, traj.track, traj.group, traj.id, traj.trial, traj.session, 0, traj.offset + dist, traj.start_index + starti - 1, traj.trial_type);   
         end 
        
         function segs = partition(inst, func, varargin)
             segs = func(inst, varargin{:});
         end
                
%         function [ V ] = compute_features(inst, feat)
%         %COMPUTE_FEATURES Computes a set of features for a trajectory
%         %   COMPUTE_FEATURES(traj, [F1, F2, ... FN]) computes features F1, F2, ..
%         %   FN for trajectory traj (features are identified by config defined 
%         %   at the beginning of this class    
%             V = [];
%             for i = 1:length(feat)
%                 V = [V, inst.compute_feature(feat(i))];
%             end
%         end            
        
        function val = compute_feature(inst, feat)            
            % see if value already cached
            if isempty(inst.feat_val_) || ~inst.feat_val_.isKey(feat.hash_value)
                val = feat.value(inst);                    
                                               
                % cache value for next time
                inst.cache_feature_value(feat.hash_value, val);
            else
                val = inst.feat_val_(feat.hash_value);
            end           
        end    
        
        function plot(inst, config, varargin)
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [clr, arn, ls, lw] = process_options(varargin, ...
                'Color', [0 0 0], 'DrawArena', 1, 'LineSpec', '-', 'LineWidth', 1);
            if arn
                ra = config.property('ARENA_R');
                x0 = config.property('CENTRE_X');
                y0 = config.property('CENTRE_Y');
                
                axis off;
                axis tight;
                xlim([0 2*ra]);
                ylim([0 2*ra]);
                daspect([1 1 1]);                
                               
                rectangle('Position', [x0 - ra, y0 - ra, ra*2, ra*2],...
                    'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
                hold on;
                axis square;
                % see if we have a platform to draw
                if config.has_property('PLATFORM_X')
                    x0 = config.property('PLATFORM_X');
                    y0 = config.property('PLATFORM_Y');
                    rp = config.property('PLATFORM_R');
                    
                    rectangle('Position',[x0 - rp, y0 - rp, 2*rp, 2*rp],...
                        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);             
                end
                
            end
            plot(inst.points(:,2), inst.points(:,3), ls, 'LineWidth', lw, 'Color', clr);           
            set(gca, 'LooseInset', [0,0,0,0]);
        end      
        
        function pts = simplify(inst, tol)
            pts = trajectory_simplify_impl(inst.points, tol);
        end                               
    end
    
    methods(Static)
        % compute a hash for a trajectory segment
        % defined here as it is useful in other situations as well
        function hash = compute_hash(set, session, track, offset, len) 
            % compute hash            
            hash = hash_value(set);
            hash = hash_combine(hash, hash_value(session));
            hash = hash_combine(hash, hash_value(track));
            hash = hash_combine(hash, hash_value(floor(offset)));
            hash = hash_combine(hash, hash_value(floor(len)));
        end
    end      
end
    
