path1 = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1\results\paper';

class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};
%300_07, 250_07, 250_09, 200_07
scenarios = {'Segmentation I','Segmentation II','Segmentation III','Segmentation IV'};

%smooth all class
scores = {[61,58,5,4,13,1,1,0,52],...
          [63,46,10,1,57,0,11,0,63],...
          [90,83,9,0,73,0,19,0,75],...
          [65,53,24,0,52,4,9,2,44]};        
samples = [63,64,90,65];

%smooth ensemble 21
scores = {[21,21,0,0,0,0,0,0,20],...
          [21,19,1,0,21,0,1,0,19],...
          [21,21,0,0,21,0,0,1,19],...
          [21,21,4,0,19,0,1,0,16]};        
samples = [21,21,21,21];

%no smooth all class
scores = {[60,61,2,3,15,1,1,0,37],...
          [63,57,13,0,56,3,6,0,34],...
          [87,89,4,0,76,0,7,0,20],...
          [63,56,22,0,57,4,5,4,17]};        
samples = [63,64,90,65];

%no smooth ensemble 21
scores = {[21,21,0,1,0,1,0,0,18],...
          [21,21,0,0,20,0,1,0,11],...
          [21,21,1,0,20,0,0,0,4],...
          [21,20,6,0,21,0,0,0,4]};        
samples = [21,21,21,21];

fpath = path1;
mkdir(fpath);
for i = 1:length(samples)
    score = scores{i};
    sample = samples(i);
    paper_fig_confidence_intervals(score,sample,class_tags,fpath,i,scenarios{i});
end