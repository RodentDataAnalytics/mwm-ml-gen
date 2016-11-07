function [LineStyle,Color,id] = return_lineformat(strat)
%RETURN_LINEFORMAT returns the specific lineformat of the strategy

    lineformat = get_lineformat;
    
    if isnumeric(strat)
        for i = 1:length(lineformat)
            if strat == lineformat{i,2}
                id = lineformat{i,1};
                Color = lineformat{i,3};
                LineStyle = lineformat{i,4};
            end
        end
    elseif iscell(strat)
        if length(strat) > 1
            id = lineformat{1,2};
            Color = lineformat{1,3};
            LineStyle = lineformat{1,4};
        elseif isequal(strat,'UD')
            id = lineformat{2,2};
            Color = lineformat{2,3};
            LineStyle = lineformat{2,4};
        else
            for i = 3:length(lineformat)
                if strat == lineformat{i,2}
                    id = lineformat{i,2};
                    Color = lineformat{i,3};
                    LineStyle = lineformat{i,4};
                end     
            end
        end
    end
end

