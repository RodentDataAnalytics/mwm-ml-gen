function pts = trajectory_speed_profile(traj, varargin)
    repr = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD);
            
    pts = trajectory_speed_impl(repr.apply(traj, varargin{:}));
    
    % take only the time and speed
    pts = pts(:, [1, 4]);
end