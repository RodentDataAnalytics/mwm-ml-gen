% Get segmentation folder
folder_name = uigetdir('Select segmentation folder');
if isequl(folder_name,0)
    return
end
% Get classifier file
[fname, pname] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select classifier');
if isequl(fname,0)
    return
end
mclassification = strcat(pname,fname);
% Define output file name and path 
[fname, pname] = uiputfile('*.csv','Output File');
if isequl(pname,0)
    return
end
output_file = strcat(pname,fname);

files = dir(fullfile(ppath,'*.mat'));
segmentations = cell(1,length(files));
for i = 1:length(files)
    load(fullfile(ppath,files(i).name));
    segmentations{i} = segmentation_configs;
end
[output,~] = match_segments(segmentations);

load(mclassification);
labels = classification_configs.CLASSIFICATION.class_map(output(:,2))';
table = [num2cell(output(:,1)), num2cell(labels)];
tags = classification_configs.CLASSIFICATION_TAGS;
for i = 1:size(table,1)
    if table{i,2} > 0
        table{i,2} = tags{table{i,2}}{1};
    else
        table{i,1} = [];
        table{i,2} = [];
    end
end
table(all(cellfun(@isempty,table),2),:) = [];

VariableNames = cell(1,length(tags)+2);
VariableNames{1} = 'Segment';
for i = 2:length(VariableNames)
    VariableNames{i} = strcat('label',num2str(i-1));
end
table{1,length(VariableNames)} = [];
table = cell2table(table,'VariableNames',VariableNames);
writetable(table,output_file,'WriteVariableNames',1);

