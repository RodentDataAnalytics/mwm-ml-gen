function [ test_result ] = check_user_input( user_input, switcher )
%CHECK_USER_INPUT Checks if all the textboxes contains appropriate values

% sanity_check, contains 0/1: 0=wrong, 1=correct
% The user's input is checked as follows:
% 1    : Animal groups, path should point to a csv file.
% 2    : Trajectory raw data, path should point to a folder.
% 3    : Output folder, path should point to a folder.
% 4-9  : Files format properties should not be empty. In case of the Group
%        Field user has the choice of either provide a csv file (1) or
%        provide a string.
% 10   : Sessions, should be a number.
% 11   : Trials per session, should have a num1,num2,...,numN format,
%        where N = Sessions.
% 12-18: All experimental properties should be numericals.

% 19   : Segment length, should be numerical.
% 20   : Segment overlap, should be numerical and <= 1 (because it is percentage).

% 17   : Labels, path should point to a csv file.
% 18   : Segment configurations, path should point to a .mat file.
% 19   : Number of clusters, should be a number.

    %% Initialize sanity_table %%
    count = 0;
    for i = 1:length(user_input)
        if iscell(user_input{1,i})
            count = count + length(user_input{1,i});
        else
            count = count + 1;
        end    
    end
    sanity_table = zeros(1,count);

    switch switcher
     case 1 
        %% Paths & Format - Experiment Settings - Experiment Properties %%     
            % animal groups file
            if exist(user_input{1,1}{1}, 'file') == 2
                sanity_table(1) = 1;
            end
            % data folder
            if exist(user_input{1,1}{2}, 'file') == 7
                sanity_table(2) = 1;
            end
            % output folder
            if exist(user_input{1,1}{3}, 'file') == 7
                sanity_table(3) = 1;
            end 
            % file format
            for i = 1:5
                if ~isempty(user_input{1,2}{i})
                    sanity_table(i+3) = 1;
                end
            end    
            % the group field
            if sanity_table(1) == 1 && sanity_table(5) == 0
                sanity_table(5) = 1;
            elseif sanity_table(1) == 0 && sanity_table(5) == 1
                sanity_table(1) = 1; 
            elseif sanity_table(1) == 0 && sanity_table(1) == 0
                sanity_table(5) = 1;
                sanity_table(1) = 1;
                disp('No animal groups specified, all animals will belong to group 1');
            else
                disp('Please provide either Group Field or animal group csv file.');
                sanity_table(5) = 0;
                sanity_table(1) = 0;
            end
            % sessions
            if isnumeric(str2num(user_input{1,3}{1})) && ~isempty(user_input{1,3}{1})
                sanity_table(9) = 1;
            end 
            % days
            if isnumeric(str2num(user_input{1,3}{3})) && ~isempty(user_input{1,3}{3})
                sanity_table(10) = 1;
            end
            % trials per session
            substrings = strsplit(user_input{1,3}{2},',');
            if sanity_table(10)==1 && length(substrings)==str2num(user_input{1,3}{3})
                count = 0;
                for i = 1:length(substrings)
                    if isnumeric(str2num(substrings{i}))
                        count = count+1;
                    end
                end
                if count==length(substrings)
                    sanity_table(11) = 1;
                end
            end   
            % experiment properties
            i = 1;
            while i<8 
                if ~isempty(user_input{1,4}{i}) && isnumeric(str2num(user_input{1,4}{i}))
                    sanity_table(i+11) = 1;
                    i = i+1;
                end    
            end
            
     case 2 
        %% Paths & Format - Experiment Settings - Experiment Properties %%     
            % animal groups file
            if exist(user_input{1,1}{1}, 'file') == 2
                sanity_table(1) = 1;
            end
            % data folder
            if exist(user_input{1,1}{2}, 'file') == 7
                sanity_table(2) = 1;
            end
            % output folder
            if exist(user_input{1,1}{3}, 'file') == 7
                sanity_table(3) = 1;
            end 
            % file format
            for i = 1:5
                if ~isempty(user_input{1,2}{i})
                    sanity_table(i+3) = 1;
                end
            end    
            % the group field
            if sanity_table(1) == 1 && sanity_table(5) == 0
                sanity_table(5) = 1;
            elseif sanity_table(1) == 0 && sanity_table(5) == 1
                sanity_table(1) = 1; 
            elseif sanity_table(1) == 0 && sanity_table(5) == 0
                sanity_table(5) = 1;
                sanity_table(1) = 1;
                disp('No animal groups specified, all animals will belong to group 1');
            else
                disp('Please provide either Group Field or animal group csv file.');
                sanity_table(5) = 0;
                sanity_table(1) = 0;
            end
            % sessions
            if isnumeric(str2num(user_input{1,3}{1})) && ~isempty(user_input{1,3}{1})
                sanity_table(9) = 1;
            end 
            % days
            if isnumeric(str2num(user_input{1,3}{3})) && ~isempty(user_input{1,3}{3})
                sanity_table(10) = 1;
            end
            % trials per session
            substrings = strsplit(user_input{1,3}{2},',');
            if sanity_table(10)==1 && length(substrings)==str2num(user_input{1,3}{3})
                count = 0;
                for i = 1:length(substrings)
                    if isnumeric(str2num(substrings{i}))
                        count = count+1;
                    end
                end
                if count==length(substrings)
                    sanity_table(11) = 1;
                end
            end   
            % experiment properties
            i = 1;
            while i<8 && ~isempty(user_input{1,4}{i}) && isnumeric(str2num(user_input{1,4}{i}))
                sanity_table(i+11) = 1;
                i = i+1;
            end       
            % segment length
            if ~isempty(user_input{1,5}{1}) && isnumeric(str2num(user_input{1,5}{1})) 
                sanity_table(19) = 1;
            end
            % segment overlap   
            if  ~isempty(user_input{1,5}{2}) && isnumeric(str2num(user_input{1,5}{2}))
                if str2num(user_input{1,5}{2}) <= 1
                    sanity_table(20) = 1;
                end    
            end

     case 3
        %% Labelling and Classification %%    
            % labels
            if exist(user_input{1,1}{1,1}, 'file') == 2
                sanity_table(1) = 1;
            end
            % segment data
            if exist(user_input{1,1}{1,2}, 'file') == 2
                sanity_table(2) = 1;
            end
            % default number of clusters
            if  ~isempty(user_input{1,2}{1}) && isnumeric(str2num(user_input{1,2}{1}))
                sanity_table(3) = 1;
            end    
    end 

    %% Outcome %%
    user_feedback(sanity_table,switcher);
    if any(sanity_table==0)
        test_result = 0; % not passed
    else
        test_result = 1; % passed
    end

end

