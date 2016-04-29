function user_feedback( sanity_table, switcher )
%USER_FEEDBACK informs the user if his input is correct

    switch switcher
     case 1 
        %% General Settings %% 
        % Path Errors
        if ~sanity_table(1)
            errordlg('File not found. Specify a correct file path for Animal Groups','File error');
        elseif ~sanity_table(2)
            errordlg('Folder not found. Specify a correct folder path for Trajectory Data','Path error');
        elseif ~sanity_table(3)
            errordlg('Folder not found. Specify a correct Output Folder path','Path error');
        % Experiment Settings Errors
        elseif ~sanity_table(4)
            errordlg('Sessions. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(5)
            errordlg('Trials per Session. The arguments needs to be numbericals and the number of arguments needs to be equal to the number of Sessions','Input Error');
        elseif ~sanity_table(6)
            errordlg('Trial Types Description. Field cannot be empty','Input Error');
        elseif ~sanity_table(7)
            errordlg('Groups Description. The number of arguments needs to be equal to the number of the available animal groups','Input Error');
        % Experiment Properties Errors
        elseif ~sanity_table(8)
            errordlg('Trial timeout. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(9)
            errordlg('Centre X. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(10)
            errordlg('Centre Y. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(11)
            errordlg('Arena radius. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(12)
            errordlg('Platform X. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(13)
            errordlg('Platform Y. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(14)
            errordlg('Platform radius. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(15)
            errordlg('Platform proximity radius. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(16)
            errordlg('Longest loop extension. Field needs to contain a numerical value','Input Error');
        % Segmentation
        elseif ~sanity_table(17)
            errordlg('Segment length. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(18)
            errordlg('Segment overlap. Field needs to contain a numerical value < = 1','Input Error');
        end
        
       case 2
        %% Labelling and classification %%
        if ~sanity_table(1)
            errordlg('File path for labelling data not found.','Input Error');
        elseif ~sanity_table(2)
            errordlg('File path for segment configurations not found.','Input Error');
        elseif ~sanity_table(3)
            errordlg('Number of clusters. Field needs to contain a numerical value','Input Error');
        end
         
       case 3   
        %% Combine classification results %%
        for i=1:length(sanity_table)
            if ~sanity_table(i)
                errordlg('File path for classification configurations not found.','Input Error');
            end 
        end    
    end
end
