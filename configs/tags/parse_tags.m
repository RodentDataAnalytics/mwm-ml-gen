function [error, contents] = parse_tags(varargin)
%PARSE_TAGS reads the configs.txt files.
%Do not modify values with '!'. These values are used internally by the
%program.

    cells = 9; % to be changed if more cells are added
    
    contents = {'','','','','','','','',''};
    error = 1;
    fmt = repmat('%s ',[1,cells]);
    
    if isequal(varargin{1},'tags_default') %default file
        if ~isdeployed 
            fileID = fopen('tags_default.txt');
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        else
            fileID = fopen(fullfile(ctfroot,'configs','tags','tags_default.txt'));
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        end
    else
        try
            ppath = char_project_path(varargin{1});
            fileID = fopen(ppath); %specified file
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        catch
            return
        end
    end
    
    contents = contents{1,1};
    fclose(fileID);
   
    % check file
    if ~isequal(contents{1,1},'ABBREVIATION') || ~isequal(contents{1,2},'DESCRIPTION') ||...
       ~isequal(contents{1,3},'ID') || ~isequal(contents{1,4},'COLOR1') ||...
       ~isequal(contents{1,5},'COLOR2') || ~isequal(contents{1,6},'COLOR3') ||...
       ~isequal(contents{1,7},'LINESTYLE') || ~isequal(contents{1,8},'KEY') ||...
       ~isequal(contents{1,9},'SPECIAL')
   
        return;
    end
    
    error = 0;
end

