function pts = trajectory_speed( traj, varargin )
    [repr] = process_options(varargin, 'DataRepresentation', base_config.DATA_REPRESENTATION_COORD);
            
    pts = trajectory_speed_impl(repr.apply(traj));
end