% This script closes all opened files. 

fIDs = fopen('all');
for i = 1:length(fIDs)
    fclose(fIDs(i))
end