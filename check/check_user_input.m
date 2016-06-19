function [ test_result ] = check_user_input( user_input, switcher )
%CHECK_USER_INPUT Checks if all the textboxes contains appropriate values

% sanity_check, contains 0/1: 0=wrong, 1=correct
% The user's input is checked as follows:
% 1    : Trajectory raw data, path should point to a folder.
% 2    : Output folder, path should point to a folder.
% 3-6  : Files format properties should not be empty.
% 7    : Sessions, should be a number (not 0).
% 8    : Trials per day, should have a num1,num2,...,numN format,
%        where N = days (not 0).
% 9    : Days, should be a number (not 0).
% 10-16: All experimental properties should be numericals.
% 17-18: Checkboxes are always correct (1).

% 19   : Segment length, should be numerical.
% 20   : Segment overlap, should be numerical and <= 1 (because it is percentage).

% Segmentation Configs: Must have a file path.
% Labelling: Must have a CSV file path.
% Number of Clusters: Must be numeric (not 0).

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
            % data folder
            if exist(user_input{1,1}{1}, 'dir') == 7
                sanity_table(1) = 1;
            end
            % output folder
            if exist(user_input{1,1}{2}, 'dir') == 7
                sanity_table(2) = 1;
            end 
            % file format
            for i = 1:4
                if ~isempty(user_input{1,2}{i})
                    sanity_table(i+2) = 1;
                end
            end    
            % sessions
            try
                c = str2num(user_input{1,3}{1});
                if ~isempty(c)
                    if c ~= 0
                        sanity_table(7) = 1;
                    end    
                end    
            catch ME   
                sanity_table(7) = 0;
            end    
            % days
            try
                c = str2num(user_input{1,3}{3});
                if ~isempty(c)
                    if c ~= 0
                        sanity_table(9) = 1;
                    end    
                end    
            catch ME   
                sanity_table(9) = 0;
            end             
            % trials per session
            substrings = strsplit(user_input{1,3}{2},',');
            try
                if sanity_table(9)==1 && length(substrings)==str2num(user_input{1,3}{3})
                    count = 0;
                    for i = 1:length(substrings)
                        if isnumeric(str2num(substrings{i}))
                            if str2num(substrings{i}) ~= 0
                                count = count+1;
                            end    
                        end
                    end
                    if count==length(substrings)
                        sanity_table(8) = 1;
                    end
                end  
            catch ME   
               sanity_table(8) = 0;
            end   
            % experiment properties
            i = 1;
            while i<8
                try
                    c = str2num(user_input{1,4}{i});
                    if ~isempty(c)
                        sanity_table(i+9) = 1;
                    end 
                    i = i+1;
                catch ME
                    sanity_table(i+9) = 0;
                end    
            end
            % checkboxes
            sanity_table(17) = 1;
            sanity_table(18) = 1;
            
     case 2 
        %% Paths & Format - Experiment Settings - Experiment Properties %%     
            % data folder
            if exist(user_input{1,1}{1}, 'file') == 7
                sanity_table(1) = 1;
            end
            % output folder
            if exist(user_input{1,1}{2}, 'file') == 7
                sanity_table(2) = 1;
            end 
            % file format
            for i = 1:4
                if ~isempty(user_input{1,2}{i})
                    sanity_table(i+2) = 1;
                end
            end    
            % sessions
            try
                c = str2num(user_input{1,3}{1});
                if ~isempty(c)
                    if c ~= 0
                        sanity_table(7) = 1;
                    end    
                end    
            catch ME   
                sanity_table(7) = 0;
            end    
            % days
            try
                c = str2num(user_input{1,3}{3});
                if ~isempty(c)
                    if c ~= 0
                        sanity_table(9) = 1;
                    end    
                end    
            catch ME   
                sanity_table(9) = 0;
            end             
            % trials per session
            substrings = strsplit(user_input{1,3}{2},',');
            try
                if sanity_table(9)==1 && length(substrings)==str2num(user_input{1,3}{3})
                    count = 0;
                    for i = 1:length(substrings)
                        if isnumeric(str2num(substrings{i}))
                            if str2num(substrings{i}) ~= 0
                                count = count+1;
                            end    
                        end
                    end
                    if count==length(substrings)
                        sanity_table(8) = 1;
                    end
                end  
            catch ME   
               sanity_table(8) = 0;
            end   
            % experiment properties
            i = 1;
            while i<8
                try
                    c = str2num(user_input{1,4}{i});
                    if ~isempty(c)
                        sanity_table(i+9) = 1;
                    end 
                    i = i+1;
                catch ME
                    sanity_table(i+9) = 0;
                end    
            end
            % checkboxes
            sanity_table(17) = 1;
            sanity_table(18) = 1;       
            % segment length
            try
                c = str2num(user_input{1,5}{1});
                if ~isempty(c)
                    sanity_table(19) = 1;
                end    
            catch ME   
                sanity_table(19) = 0;
            end                    
            % segment overlap   
            try
                c = str2num(user_input{1,5}{2});
                if ~isempty(c)
                    if c <= 1
                        sanity_table(20) = 1;
                    end    
                end    
            catch ME   
                sanity_table(20) = 0;
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
            try
                c = str2num(user_input{1,2}{1});
                if ~isempty(c)
                    if c ~= 0
                        sanity_table(3) = 1;   
                    end    
                end    
            catch ME   
                sanity_table(3) = 0;
            end               
    end 

    %% Outcome %%
    check_user_feedback(sanity_table,switcher);
    if any(sanity_table==0)
        test_result = 0; % not passed
    else
        test_result = 1; % passed
    end

end

