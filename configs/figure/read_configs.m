function [ contents ] = read_configs
%READ_CONFIGS reads the configs.txt

    fmt = repmat('%s ',[1,3]);
    if ~isdeployed
        fileID = fopen('configs.txt');
        contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
    else
        fileID = fopen(fullfile(ctfroot,'configs','figure','configs.txt'));
        contents = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',','); 
    end
    contents = contents{1,1};
    fclose(fileID);
end

