function [contents] = parse_tags(varargin)
%PARSE_TAGS reads the configs.txt files and returns 
%ABBREVIATION,DESCRIPTION,ID,WEIGHT,COLOR1,COLOR2,COLOR3,LINESTYLE.
%COLOR1,COLOR2,COLOR3 is returned as {[n1,n2,n3]}, where n = numeric.
%Do not modify values with '!'. These values are used internally by the
%program.
%Returns an 1x6 cell array

    fmt = repmat('%s ',[1,8]);
    
    if isempty(varargin)
        if ~isdeployed 
            fileID = fopen('tags.txt');
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        else
            fileID = fopen(fullfile(ctfroot,'configs','tags','tags.txt'));
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',','); 
        end
    else
        if isequal(varargin{1},'tags_default') %default file
            if ~isdeployed 
                fileID = fopen('tags_default.txt');
                contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
            else
                fileID = fopen(fullfile(ctfroot,'configs','tags','tags_default.txt'));
                contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
            end
        else
            fileID = fopen(varargin{1}); %specified file
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        end
    end
    contents = contents{1,1};
    fclose(fileID);
   
    % check file
    if ~isequal(contents{1,1},'ABBREVIATION') || ~isequal(contents{1,2},'DESCRIPTION') ||...
       ~isequal(contents{1,3},'ID') || ~isequal(contents{1,4},'WEIGHT') ||...   
       ~isequal(contents{1,5},'COLOR1') || ~isequal(contents{1,6},'COLOR2') ||...   
       ~isequal(contents{1,7},'COLOR3') || ~isequal(contents{1,8},'LINESTYLE')
        contents = {'','','','','','','',''};
        return
    end
    
    for i = 2:size(contents,1)
        contents{i,3} = str2num(contents{i,3});
        contents{i,4} = str2num(contents{i,4});
        color1 = str2num(contents{i,5});
        color2 = str2num(contents{i,6});
        color3 = str2num(contents{i,7});
        contents{i,5} = [color1,color2,color3];
        contents{i,6} = contents{i,8};
    end 
    contents{1,6} = 'LINESTYLE';
    contents = contents(1:end,1:6);
    
    % fix the LineStyle
    for i = 2:size(contents,1)
        if isequal(contents{i,6},'Solid')
            contents{i,6} = '-';
        elseif isequal(contents{i,6},'Dashed') 
            contents{i,6} = '--';
        elseif isequal(contents{i,6},'Dotted')  
            contents{i,6} = ':';
        end    
    end
end

