% Get classifier file
[fname, pname] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select classifier');
if isequal(fname,0)
    return
end
mclassification = strcat(pname,fname); 
% Define output file name and path 
[fname, pname] = uiputfile('*.csv','Output File');
if isequal(pname,0)
    return
end
output_file = strcat(pname,fname);
tmp = strsplit(fname,'.csv');
output_file_ud = strcat(pname,strcat(tmp{1},'_UD.csv'));


load(mclassification);
labels = classification_configs.CLASSIFICATION.class_map';
labels_idx = find(labels ~= 0);
table = [num2cell(labels_idx),num2cell(labels(labels_idx))];
labels_idx = find(labels == 0);
table_ud = [num2cell(labels_idx),num2cell(labels(labels_idx))];
tags = classification_configs.CLASSIFICATION_TAGS;

for i = 1:size(table,1)
    table{i,2} = tags{table{i,2}}{1};
end
for i = 1:size(table_ud,1)
    table_ud{i,2} = 'UD';
end

VariableNames = cell(1,length(tags)+2);
VariableNames{1} = 'Segment';
for i = 2:length(VariableNames)
    VariableNames{i} = strcat('label',num2str(i-1));
end
table{1,length(VariableNames)} = [];
table = cell2table(table,'VariableNames',VariableNames);
writetable(table,output_file,'WriteVariableNames',1);
table_ud{1,length(VariableNames)} = [];
table_ud = cell2table(table_ud,'VariableNames',VariableNames);
writetable(table_ud,output_file_ud,'WriteVariableNames',1);

