classdef trajectory_feature < handle
    %TAG Groups together some commmon attributes of trajectories
    properties(GetAccess = 'public', SetAccess = 'protected')
        % short and long descriptions
        abbreviation = '';            
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        hash_ = [];
        f_ = [];
        start_time_offset_ = -1;
        dt_ = -1;
    end
    
    methods
        %% constructor        
        function inst = trajectory_feature(abbrev, desc, func, rarg, prop, varargin)   
            inst.abbreviation = abbrev;
            if nargin < 4
                rarg = 1;
            end
            if nargin < 5
                prop = {};
            end               
            [inst.start_time_offset_, inst.dt_] = process_options(varargin, ...
                'StartTimeOffset', -1, ...
                'TLength', -1 ...
            );
            
            inst.f_ = function_wrapper(desc, func, rarg, prop, varargin{:});
        end
        
        function val = hash_value(inst)
           val = inst.f_.hash_value;
           val = hash_combine(val, inst.start_time_offset_);
           val = hash_combine(val, inst.dt_);           
        end
        
        function set_parameters(inst, config)
            inst.f_.set_parameters(config);            
        end
                    
        function ret = value(inst, traj)      
            % compute over the whole trajectory or just a sub-segment?
            if inst.start_time_offset_ > 0 || inst.dt_ > 0
                if inst.start_time_offset_ > 0
                    toff = inst.start_time_offset_;
                else
                    toff = 0;
                end
                if inst.dt_ > 0
                    dt = inst.dt_;
                else
                    % to infinity - will take the rest of the trajectory
                    dt = 1e10;
                end
                seg = traj.sub_segment_time(toff, dt);
                ret = inst.f_.apply1(seg);    
            else                        
                ret = inst.f_.apply1(traj);
            end
        end
        
        function desc = description(inst)
            desc = inst.f_.description;
        end
    end
end