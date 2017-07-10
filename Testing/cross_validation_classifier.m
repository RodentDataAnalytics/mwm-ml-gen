project_path = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1';
%Mclass = 'class_989_8447_300_07_11_21_mr0';
%Mclass = 'class_989_8447_300_07_28_1_mr0';
%Mclass = 'class_1268_10388_250_07_11_21_mr0';
%Mclass = 'class_1268_10388_250_07_43_1_mr0';
%Mclass = 'class_1067_13283_200_07_11_21_mr0';
%Mclass = 'class_1067_13283_200_07_25_1_mr0';
Mclass = 'class_1268_10388_250_07_8_1_mr0';
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
    % CROSS_VALIDATE
%     for f = 1:folds
%         input_labels = classification_configs.CLASSIFICATION.input_labels;
%         nlabels = classification_configs.CLASSIFICATION.nlabels;
%         non_empty_labels_idx = [];
%         cv_class_maps = cv_res1{1,f};
%         for w = 1:length(input_labels)
%             tmp = input_labels{w};
%             if tmp ~= -1
%                 non_empty_labels_idx = [non_empty_labels_idx, w];     
%                 % in case that we have one label only, and the segment
%                 % could not be classified adopt the manual label
%                 if length(tmp) == 1 && tmp(1) > 0
%                     if cv_class_maps(w) == 0
%                         cv_class_maps(w) = tmp(1);
%                     end
%                 end
%             end
%         end
%         % show wrongly classified trajectories
%         n = 0;
%         errors = zeros(1, nlabels);
%         for w = 1:nlabels
%             if tst_set(w) ~= 1
%                 continue;
%             end
%             idx = non_empty_labels_idx(w);
%             tmp = input_labels{idx};
%             if tmp ~= -1                  
%                 n = n + 1;
%                 if cv_class_maps(idx) ~= 0 && ~any(tmp == cv_class_maps(idx))
%                     errors(w) = 1;  
%                 end
%             end
%         end     
%         nerrors = sum(errors);
%         if n > 0
%             perrors = nerrors / n;            
%         end 
%     end

    
%     for i = 1:10
%         cv_res1{1,i} = res.results(i).class_map;
%         tmp = find(res.results(i).test_set == 1);
%         tmp = classification_configs.CLASSIFICATION.non_empty_labels_idx(tmp);
%         cv_res1{2,i} = tmp;
%         labels = classification_configs.CLASSIFICATION.input_labels(tmp);
%         cv_res1{3,i} = labels;
%     end
%     score = zeros(folds,2);
%     p = 0;
%     for f = 1:folds
%         for l = 1:length(cv_res1{2,f})
%             idx = cv_res1{2,f}(l);
%             lab = cv_res1{3,f}(l);
%             for li = 1:length(lab)
%                 if cv_res1{1,f}(idx) == lab{li}
%                     p = p+1;
%                     break;
%                 end
%             end
%         end
%         score(f,1) = p;
%         score(f,2) = length(cv_res1{2,f});
%         p = 0;
%     end 
%     
%     zz = [];
%     for i = 1:size(score,1)
%         zz = [zz;score(i,1)*100/score(i,2)];
%     end
%     a = [a;100 - mean(zz)];  
  
