function [ test_result ] = check_user_input( user_input, switcher )
%CHECK_USER_INPUT Checks if all the textboxes contains appropriate values

% sanity_check, contains 0/1: 0=wrong, 1=correct
% The user's input is checked as follows:
% 1   : Animal groups, path should point to a csv file.
% 2   : Trajectory raw data, path should point to a folder.
% 3   : Output folder, path should point to a folder.
% 4   : Sessions, should be a number.
% 5   : Trials per session, should have a num1,num2,...,numN format,
%       where N = Sessions.
% 6   : Trial types description, should not be empty.
% 7   : Groups description, should have a str1,str2,...,strN format,
%       where N = number of animal groups. (THIS RULE IS NOT IMPLEMENTED)
% 8-16: All experimental properties should be numericals.
% 17  : Segment length, should be numerical.
% 18  : Segment overlap, should be numerical and <= 1 (because it is percentage).
% 19  : Labels, path should point to a csv file.
% 20  : Segment configurations, path should point to a .mat file.
% 21  : Number of clusters, should be a number.
% 22  : Combine classification results, all selected files should be .mat

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
        %% Paths - Experiment Settings - Experiment Properties - Segmentation Properties %%     
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
            % sessions
            if isnumeric(str2num(user_input{1,2}{1})) && ~isempty(user_input{1,2}{1})
                sanity_table(4) = 1;
            end 
            % trials per session
            substrings = strsplit(user_input{1,2}{2},',');
            if sanity_table(4)==1 && length(substrings)==str2num(user_input{1,2}{1})
                count = 0;
                for i = 1:length(substrings)
                    if isnumeric(str2num(substrings{i}))
                        count = count+1;
                    end
                end
                if count==length(substrings)
                    sanity_table(5) = 1;
                end
            end    
            % trials types description
            if ~isempty(user_input{1,2}{3})
                sanity_table(6) = 1;
            end
            % groups description
            % substrings = strsplit(user_input{1,2}{4},',');
            % if sanity_table(4)==1 && length(substrings)==str2num(user_input{1,2}{1})
                 sanity_table(7) = 1;
            % end

            % experiment properties
            i = 1;
            while i<10 && ~isempty(user_input{1,3}{i}) && isnumeric(str2num(user_input{1,3}{i}))
                sanity_table(i+7) = 1;
                i = i+1;
            end 
            % segment length
            if ~isempty(user_input{1,4}{1}) && isnumeric(str2num(user_input{1,4}{1})) 
                sanity_table(17) = 1;
            end
            % segment overlap   
            if  ~isempty(user_input{1,4}{2}) && isnumeric(str2num(user_input{1,4}{2}))
                if str2num(user_input{1,4}{2}) <= 1
                    sanity_table(18) = 1;
                end    
            end

     case 2
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

     case 3
        %% Merge Results %%    
            % classification results files
            for i=1:length(user_input)
                if exist(user_input{1,i}, 'file') == 2
                    sanity_table(i) = 1; 
                end
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

