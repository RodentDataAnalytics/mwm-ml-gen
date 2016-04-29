function [ rat, trial, pts, day ] = read_trajectory_ethovision( fn, varargin)
%READ_TRAJECTORY Reads a trajectory from a file (native Ethovision format
%supported)
    % use a 3rd party function to read the file; matlab's csvread is    
    % totaly useless for anything other than perfectly formatted, value
    % only CSV files        
    [animal_tags, trial_tags, day_tags, day_fmt] = process_options(varargin, 'AnimalTags', {'rat', 'id'}, 'TrialTags', {'trial'}, ...
                                                          'DayTags', {'day'}, 'DayFormat', '%d');
    if ~exist(fn, 'file')
        error('Non-existent file');
    end
    data = robustcsvread(fn);
    err = 0;
    pts = [];
    day = 0;
    
    %%
    %% parse the file
    %%
    for i = 1:length(animal_tags)
        l = strmatch(animal_tags{i}, data(:, 1));
        if ~isempty(l)
            break;
        end               
    end
    if isempty(l)
        err = 1;            
    end
    rat = sscanf(data{l, 2}, '%d');
    for i = 1:length(trial_tags)
        l = strmatch(trial_tags{i}, data(:, 1));
        if ~isempty(l)
            break;
        end               
    end            
    if isempty(l)
        err = 1;
    end    
    trial = sscanf(data{l, 2}, '%d');
    l = [];
    for i = 1:length(day_tags)
        l = strmatch(day_tags{i}, data(:, 1));
        if ~isempty(l)
            break;
        end               
    end            
    if ~isempty(l)
        day = sscanf(data{l, 2}, day_fmt);        
    end    
    
    % look for beggining of trajectory points
    l = strmatch('Sample no.', data(:, 1));
    if isempty(l)
        err = 1;
    else
       for i = (l + 1):length(data)
           if ~isempty(data{i, 1})
               % extract time, X and Y coordinates
               t = sscanf(data{i, 2}, '%f');
               x = sscanf(data{i, 3}, '%f');
               y = sscanf(data{i, 4}, '%f');
               % discard missing smaples
               if ~isempty(t) && ~isempty(x) && ~isempty(y)
                   pts = [pts; t x y];
               end
           end
       end
    end
        
    if err
        exit('invalid file format');
    end
end