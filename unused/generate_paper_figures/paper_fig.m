class_tags = classification_configs.CLASSIFICATION_TAGS;
class_tags{1,9} = {'tr','Transitions',0,0};

% scores = {[20,20,0,0,20,0,2,0,19],...
%           [20,20,0,0,17,0,0,0,20],...
%           [30,30,0,0,26,0,0,0,29],...
%           [10,10,0,0,10,0,0,0,9]};        
% samples = [20,20,30,10];
% scenarios = {'sc1','sc2','sc3','sc4'};

scores = {[20,20,6,0,18,0,5,0,19]};        
samples = 20;
scenarios = {'sc1'};

for i = 1:length(samples)
    score = scores{i};
    sample = samples(i);
    fpath = strcat('D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data\results\paper');
    mkdir(fpath);
    paper_fig_confidence_intervals(score,sample,class_tags,fpath)
end