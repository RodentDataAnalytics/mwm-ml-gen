function [ groups ] = validate_groups( groups, varargin )
%VALIDATE_GROUPS check if user's groups input is correct
% Returns:
% 1: if we have only one group
% g1,g2: where g1,g2 are the numbers of the groups
% -1: in case of wrong input

    % Original data:
    if length(varargin) > 2
        if isequal(varargin{1,3},'original_results');
            groups = [1,2];
            return;
        end
    end    
    
    % Other data 
    if length(groups) == 1 %Only one animal group
        groups = 1;
        return
    end    
    if iscell(varargin) % e.g. {1,2}
        groups_ = strsplit(varargin{1,1}{1,1},',');
        if length(groups_) > 2
            groups = -1;
            disp('Please specify 2 animal groups');
            return
        end    
        if length(groups_) ~= 2 % one group only
            g1 = str2num(groups_{1,1});
            %check if group is a number
            if isempty(g1)
                groups = -1;
                disp('Wrong input for animal group.');
                return
            else
                g1_ = find(groups==g1);
                %check if we have this group
                if ~isempty(g1_)
                    groups = g1;
                    fprintf('\nRunning statistics for animal group %d.\n',groups);
                    pause(1);
                    return;
                else    
                    groups = -1;
                    disp('The specified animal group does not exist.');
                    return
                end
            end    
        else % two groups (other numbers will be ignored)
            g1 = str2num(groups_{1,1});
            g2 = str2num(groups_{1,2});
            %check if groups are numbers
            if isempty(g1) || isempty(g2) || g1==g2
                groups = -1;
                disp('Wrong input for animal groups. Specify one or two different animal groups.');
                return
            else
                g1_ = find(groups==g1);
                g2_ = find(groups==g2);
                %check if we have these groups
                if ~isempty(g1_) && ~isempty(g2_)
                    groups = [g1,g2];
                    return
                else
                    groups = -1;
                    disp('Wrong input for animal groups. The specified group(s) do no exist');
                    return
                end    
            end
        end    
    end
end

