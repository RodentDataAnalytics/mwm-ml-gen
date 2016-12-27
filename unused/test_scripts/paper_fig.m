% class I
%score = [20,20,4,0,20,0,2,0,19];
%sample = 20;
% % class II
score = [19,20,0,0,17,0,0,0,20];
sample = 20;
% % class III
% score = [30,30,0,0,25,0,0,0,29];
% sample = 30;

fpath = 'C:\Users\Avgoustinos\Desktop\New Folder\EPFL_original_data\results\paper\zzz';
class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};

create_pvalues_confidence_intervals(score,sample,class_tags,fpath);