% DESCRIPTION: Exports the current figure into different formats.
% ARGUMENTS:
%           -flag: if it is set to 1 the default export format .eps is
%                  being used.
%
%           -get_current_figure: figure for exporting, for current "active"
%                                figure use gcf.
%
%           -get_path: path in which we want the figure to be exported.
%
%           -get_name: name of the generated file (without extension).
%
%
% EXAMPLE_1: export_figure(1, gcf, 'C:\', 'myfig_1');
%            -> generates: C:\myfig_1.fig
%
% EXAMPLE_2: export_figure(0, gcf, 'C:\', 'myfig_2'); -> 
%            requests a user's input:
%                1 = .fig file, 2 = .eps file
%            generates one of the following:
%                C:\myfig_1.fig OR C:\myfig_1.eps


function export_figure(flag, get_current_figure, get_path, get_name)

    if flag == 1
        saveas(get_current_figure, strcat(get_path,get_name,'.fig')); %default export format
        saveas(get_current_figure, strcat(get_path,get_name,'.eps'),'epsc2');
        % we need to specify eps color (epsc or epsc2) as the format
        % parameter or else the exported picture will be black & white
    else
        while (1)
            prompt = sprintf('Exporting...: \n1. .fig format \n2. .eps format \nChoice: ');
            user_input = input(prompt)
            if user_input == 1
                saveas(get_current_figure, strcat(get_path,get_name,'.fig'));
                break;
            elseif user_input == 2
                saveas(get_current_figure, strcat(get_path,get_name,'.eps'),'epsc2');
                break;
            else
                prompt = 'Wrong input'
            end
        end
    end
end
