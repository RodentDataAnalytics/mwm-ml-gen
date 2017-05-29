function groups = select_groups(my_trajectories)
%SELECT_GROUPS allows the user to select which one or two groups he wants
%in order to generate the results

% groups = -1: only one group is available, no need for input request
% groups = -2: error, wrong input

    % find available animal groups
    groups = arrayfun( @(t) t.group, my_trajectories.items);
    groups = unique(groups);
    % if we have more than one groups ask which one or two groups
    if length(groups) > 1
        prompt={'Choose one or two animal groups (example: 2 or 1,3)'};
        name = 'Choose groups';
        defaultans = {''};
        options.Interpreter = 'tex';
        user = inputdlg(prompt,name,[1 30],defaultans,options);
        if isempty(user)
            groups = -2;
            return
        end
    else
        groups = -1;
        return
    end    
    
    % check if groups are correct
    user = str2num(user{1});
    if isempty(user)
        groups = -2;
    else
        for i = 1:length(user)
            if ~any(groups == user(i))
                groups = -2;
                break;
            end
        end
    end
    if groups == -2
        errordlg('Wrong group(s) input','Input Error');
    else
        groups = user;
    end
end

