function demo(mode,varargin)
%DEMO generates the published results

    user_path = initialization;
    
    %% Terminal Mode
    % No GUI elements --> UDER DEVELOPMENT
    if mode == 0
        flag = 1;
        disp('Generating original results...');
        disp('Type 1 or 2 to import the equivalent dataset or ''q/Q'' to exit');
        while flag
            prompt='Choice: ';
            setup = input(prompt,'s');
            if strcmp(setup,'q') || strcmp(setup,'Q')
                return;
            end    
            setup = str2double(setup);
            try
                if setup == 1 || setup == 2
                    flag = 0;
                else
                    disp('Input must be 1 or 2 or q/Q.');
                end
            catch
                 disp('Input must be 1 or 2 or q/Q.');
            end               
        end
    %% GUI Mode
    % With GUI elements        
    elseif mode == 1
%         prompt={'Type 1 or 2 to import the equivalent setup or ''q/Q'' to exit'};
%         name = 'Published';
%         defaultans = {'1'};
%         options.Interpreter = 'tex';
%         setup = inputdlg(prompt,name,[1 30],defaultans,options);
%         if isempty(setup)
%             return
%         end
%         setup = str2double(setup{1});
%         try
%             if setup ~= 1 && setup ~= 2
%                 warndlg('Input must be 1 or 2 or q/Q.','Error');
%                 return
%             end
%         catch
%              warndlg('Input must be 1 or 2 or q/Q.','Error');
%              return
%         end  
        setup = 1;
        demo_gui(setup,user_path);
    end
end

