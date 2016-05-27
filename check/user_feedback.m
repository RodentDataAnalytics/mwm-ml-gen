function user_feedback( sanity_table, switcher )
%USER_FEEDBACK informs the user if his input is correct

    switch switcher
     case 1 
        %% General Settings 
        % Path Errors
        if ~sanity_table(1)
            errordlg('File not found. Specify a correct file path for Animal Groups','File error');
        elseif ~sanity_table(2)
            errordlg('Folder not found. Specify a correct folder path for Trajectory Data','Path error');
        elseif ~sanity_table(3)
            errordlg('Folder not found. Specify a correct Output Folder path','Path error');
        % Files Format Errors
        elseif ~sanity_table(4)
            errordlg('ID Field. Field needs to contain the animal id field name as specified in the csv file','Input Error');
        elseif ~sanity_table(5)
            errordlg('Group Field. Field needs to contain the animal group field name as specified in the csv file','Input Error');
        elseif ~sanity_table(6)
            errordlg('Trial Field. Field needs to contain the animal trial field name as specified in the csv file','Input Error');
        elseif ~sanity_table(7)
            errordlg('Rec Time Field. Field needs to contain the recorded time field name as specified in the csv file','Input Error');
        elseif ~sanity_table(8)
            errordlg('X Field. Field needs to contain the X coordinates field name as specified in the csv file','Input Error');
        elseif ~sanity_table(9)
            errordlg('Y Field. Field needs to contain the Y coordinates field name as specified in the csv file','Input Error'); 
        % Experiment Settings Errors
        elseif ~sanity_table(10)
            errordlg('Sessions. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(11)
            errordlg('Days. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(12)
            errordlg('Trials per Session. The arguments needs to be numbericals and the number of arguments needs to be equal to the number of Sessions','Input Error');            
        % Experiment Properties Errors
        elseif ~sanity_table(13)
            errordlg('Trial timeout. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(14)
            errordlg('Centre X. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(15)
            errordlg('Centre Y. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(16)
            errordlg('Arena radius. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(17)
            errordlg('Platform X. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(18)
            errordlg('Platform Y. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(19)
            errordlg('Platform radius. Field needs to contain a numerical value','Input Error');
        end
        
     case 2 
        %% Segmentation
        % Path Errors
        if ~sanity_table(1)
            errordlg('File not found. Specify a correct file path for Animal Groups','File error');
        elseif ~sanity_table(2)
            errordlg('Folder not found. Specify a correct folder path for Trajectory Data','Path error');
        elseif ~sanity_table(3)
            errordlg('Folder not found. Specify a correct Output Folder path','Path error');
        % Files Format Errors
        elseif ~sanity_table(4)
            errordlg('ID Field. Field needs to contain the animal id field name as specified in the csv file','Input Error');
        elseif ~sanity_table(5)
            errordlg('Group Field. Field needs to contain the animal group field name as specified in the csv file','Input Error');
        elseif ~sanity_table(6)
            errordlg('Trial Field. Field needs to contain the animal trial field name as specified in the csv file','Input Error');
        elseif ~sanity_table(7)
            errordlg('Rec Time Field. Field needs to contain the recorded time field name as specified in the csv file','Input Error');
        elseif ~sanity_table(8)
            errordlg('X Field. Field needs to contain the X coordinates field name as specified in the csv file','Input Error');
        elseif ~sanity_table(9)
            errordlg('Y Field. Field needs to contain the Y coordinates field name as specified in the csv file','Input Error'); 
        % Experiment Settings Errors
        elseif ~sanity_table(10)
            errordlg('Sessions. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(11)
            errordlg('Days. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(12)
            errordlg('Trials per Session. The arguments needs to be numbericals and the number of arguments needs to be equal to the number of Sessions','Input Error');            
        % Experiment Properties Errors
        elseif ~sanity_table(13)
            errordlg('Trial timeout. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(14)
            errordlg('Centre X. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(15)
            errordlg('Centre Y. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(16)
            errordlg('Arena radius. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(17)
            errordlg('Platform X. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(18)
            errordlg('Platform Y. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(19)
            errordlg('Platform radius. Field needs to contain a numerical value','Input Error');     
        % Segmentation
        elseif ~sanity_table(20)
            errordlg('Segment length. Field needs to contain a numerical value','Input Error');
        elseif ~sanity_table(21)
            errordlg('Segment overlap. Field needs to contain a numerical value < = 1','Input Error');
        end
        
     case 3
        %% Labelling and classification 
        if ~sanity_table(1)
            errordlg('File path for labelling data not found.','Input Error');
        elseif ~sanity_table(2)
            errordlg('File path for segment configurations not found.','Input Error');
        elseif ~sanity_table(3)
            errordlg('Number of clusters. Field needs to contain a numerical value','Input Error');
        end
          
    end
end
