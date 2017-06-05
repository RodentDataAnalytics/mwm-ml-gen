class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};

%49 CLUSTERS
scores = {[21,21,0,1,0,0,0,0,18],...
          [21,19,2,0,21,0,0,0,20],...
          [21,19,1,0,20,0,2,0,18],...
          [21,20,5,0,17,0,8,0,21]};        
samples = [21,21,21,21];
scenarios = {'sc1','sc2','sc3','sc4'};
path1 = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1_49CLUSTERS\results\paper';

%VARIED CLUSTERS
scores = {[21,21,0,1,0,0,0,0,18],...
          [21,16,4,0,21,0,1,0,20],...
          [21,21,0,0,19,0,0,1,18],...
          [21,20,4,0,17,0,1,0,20]};        
samples = [21,21,21,21];
scenarios = {'Segmentation I','Segmentation II','Segmentation III','Segmentation IV'};
path2 = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1_VARIEDCLUSTERS\results\paper';

paths = {path1,path2};

for c = 1:length(paths)
    fpath = paths{c};
    mkdir(fpath);
    for i = 1:length(samples)
        score = scores{i};
        sample = samples(i);
        paper_fig_confidence_intervals(score,sample,class_tags,fpath,i,scenarios{i});
    end
end