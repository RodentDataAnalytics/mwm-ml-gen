function [contents] = parse_tags(varargin)
%PARSE_TAGS reads the configs.txt files and returns 
%ABBREVIATION,DESCRIPTION,ID,WEIGHT,COLOR1,COLOR2,COLOR3,LINESTYLE.
%COLOR1,COLOR2,COLOR3 is returned as {[n1,n2,n3]}, where n = numeric.
%Do not modify values with '!'. These values are used internally by the
%program.
%Returns an 1x6 cell array

    fmt = repmat('%s ',[1,8]);
    if ~isdeployed
        if isempty(varargin)
            fileID = fopen('tags.txt');
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        else % return default values
            fileID = fopen('tags_default.txt');
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        end    
    else
        if isempty(varargin)
            fileID = fopen(fullfile(ctfroot,'configs','tags.txt'));
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',','); 
        else % return default values
            fileID = fopen(fullfile(ctfroot,'configs','tags_default.txt'));
            contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
        end              
    end
    contents = contents{1,1};
    fclose(fileID);
   
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

end

