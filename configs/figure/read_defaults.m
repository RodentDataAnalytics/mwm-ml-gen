function [ contents ] = read_defaults
%READ_DEFAULTS reads the configs_defaults.txt

    fmt = repmat('%s ',[1,3]);
    if ~isdeployed
        fileID = fopen('configs_default.txt');
        contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
    else
        fileID = fopen(fullfile(ctfroot,'configs','figure','configs_default.txt'));
        contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',','); 
    end
    contents = contents{1,1};
    fclose(fileID);
end

