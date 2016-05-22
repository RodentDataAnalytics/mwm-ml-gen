function [ tags_data ] = read_tags( fn )
%LOAD_TAGS reads tag data from a csv file

%% Determine if csv file is correct %%
file = fopen(fn);
while ~feof(file)    
    line = textscan(fgetl(file),'%s','Delimiter',',');
    % each line should have at least 1 numerical cell
    if length(line{1,1}) < 1     
        error('read_tags:InvalidFileFormat',['The input file ',fn,' is invalid']);
    else   
        if isempty(str2num(line{1,1}{1}))
            error('read_tags:InvalidFileFormat',['The input file ',fn,' is invalid']);
        end 
    end  
end 
fclose(file);

%% Load the data %%
file = fopen(fn);
j=1;
while ~feof(file)
    line = textscan(fgetl(file),'%s','Delimiter',',');
    tags = {};
    traj_seg = sscanf((line{1, 1}{1}), '%d');
    for i = 2:length(line{1, 1});
        if ~strcmp(line{1, 1}{i},'')
            tags{i-1} = sscanf((line{1, 1}{i}), '%s');
        else
            break;
        end    
    end    
    tags_data{1,j} = [traj_seg,{tags}];
    j=j+1;
end
fclose(file);

end

