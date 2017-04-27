function [ mode, obj, fpath ] = browse_activation_function(varargin)
%BROWSE_ACTIVATION_FUNCTION 
    
    mode = 0;
    obj = 0;
    
    % load the file and check if it the file is correct
    error = 1;
    while error
        if ~isempty(varargin) %as function
            [FN_group,PN_group] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select a segmentation configuration file',char(varargin{1}));
        else %standalone
            [FN_group,PN_group] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select a segmentation configuration file');
        end        
        if PN_group == 0
            return;
        end 
        fpath = strcat(PN_group,FN_group);
        load(fpath);
        % check if it is segmentation_configs object
        if exist('segmentation_configs','var')
            if isa(segmentation_configs,'config_segments')
                error = 0;
                mode = 1;
                obj = segmentation_configs;
            end
        % check if it is classification_configs object
        elseif exist('classification_configs','var')
            if isa(classification_configs,'config_classification')
                error = 0;
                mode = 2;
                obj = classification_configs;
            end
        % check if it is trajectories object
        elseif exist('my_trajectories','var')
            if isa(my_trajectories,'trajectories')
                error = 0;
                mode = 3;
                obj = my_trajectories;
            end
        end
    end

end

