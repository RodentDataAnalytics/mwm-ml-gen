project_path = 'D:\Avgoustinos\Documents\MWMGEN\EPFL_original_data';
Mclass = 'class_988_8447_300_07_41_1_mr0';
Mclass = 'class_1261_10388_250_07_65_1_mr0';
Mclass = 'class_2445_29476_250_09_91_1_mr0';
Mclass = 'class_1080_13283_200_07_50_1_mr0';
folds = 10;

files = dir(fullfile(project_path,'Mclassification',Mclass,'*.mat'));
[~,idx] = sort_classifiers(files);
files = files(idx);

[error,labels,~,seg_length,seg_overlap,~,~,threshold] = split_mclassification_name(Mclass);
if error
    return
end
threshold = strsplit(threshold,'mr');
threshold = str2double(threshold{2});
tmp = strcat('labels_',labels,'_',seg_length,'_',seg_overlap,'_check');
check_labs_path = fullfile(project_path,'labels',tmp,'labels');
CVfiles = dir(fullfile(check_labs_path,'*.mat'));

a = [];
b = [];
for i = 1:length(files) %for each ensemble
    load(fullfile(project_path,'Mclassification',Mclass,files(i).name));
    cv_res1 = cell(5,folds);
    res1 = [];
    %CVclass_maps = cell(1,folds);
    %for each num_cl find the label_cv
    for j = 1:length(classification_configs.DEFAULT_NUMBER_OF_CLUSTERS);
        cl = classification_configs.DEFAULT_NUMBER_OF_CLUSTERS(j);
        for f = 1:length(CVfiles);
            tmp = strsplit(CVfiles(f).name,'_');
            if str2double(tmp{2}) == cl %we want the 'clustering_cl'
                load(fullfile(check_labs_path,CVfiles(f).name));
                break;
            end
        end
        res.compress;
        res1 = [res1, res];
    end
    %collect folds per classifier
    for f = 1:folds
        cv_class_maps = [];
        %collect all the class_maps
        for j = 1:length(res1)
            tmp = res1(j);
            cv_class_maps = [cv_class_maps ; tmp.results(f).class_map];
        end
        %majority voting
        cv_class_map = majority_rule('', cv_class_maps, threshold, 'CROSS_VALIDATE', 1);
        %store boosted result
        cv_res1{1,f} = cv_class_map; 
        %store test fold labels and indexes
        tmp = find(res.results(f).test_set == 1);
        tmp = classification_configs.CLASSIFICATION.non_empty_labels_idx(tmp);
        cv_res1{2,f} = tmp;
        labels = classification_configs.CLASSIFICATION.input_labels(tmp);
        cv_res1{3,f} = labels;
        
        cv_res1{4,f} = res.results(f).test_set;
        cv_res1{5,f} = res.results(f).training_set;
    end
    % CROSS_VALIDATE
    z = [];
    for f = 1:folds
        seg = classification_configs.CLASSIFICATION.segments;
        nc = classification_configs.CLASSIFICATION.classes;
        lbls = classification_configs.LABELLING_MAP;
        train_set = cv_res1{5,f};
        tst_set = cv_res1{4,f};
        next = 0;
        cstr = 0;
        cm = cv_res1{1,f};
        ci = 0;
        ccm = 0;
        ce = 0;
        cl = classification_configs.CLASSIFICATION_TAGS;
        inst = clustering_results(seg, nc, lbls, train_set, tst_set, next, cstr, cm, ci, ccm, ce, cl);
        z = [z,inst];
    end   
    zcv = clustering_cv_results(z);
    a = [a ; 100*zcv.mean_perrors];
    b = [b ; 100*zcv.mean_perrors_true];
end
  
