ppath = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1\classification\class_1049_13283_200_07';

files = dir(fullfile(ppath,'*.mat'));
class_maps = [];
for i = 1:length(files)
    load(fullfile(ppath,files(i).name));
    class_maps = [class_maps;classification_configs.CLASSIFICATION.class_map];
end

tags = unique(class_maps);
agreement_100 = [];
agreement_90 = [];
agreement_80 = [];
agreement_50 = [];
agreement_30 = [];
agreement_20 = [];
agreement_10 = [];

count = 0;
for i = 1:size(class_maps,2)
    for j = 2:length(tags)
        tmp = find(class_maps(:,i) == tags(j));
        if length(tmp) == size(class_maps,1)
            agreement_100 = [agreement_100,i];
        end
        if length(tmp) >= size(class_maps,1)*90/100
            agreement_90 = [agreement_90,i];
        end        
        if length(tmp) >= size(class_maps,1)*80/100
            agreement_80 = [agreement_80,i];
        end     
        if length(tmp) >= size(class_maps,1)*50/100
            agreement_50 = [agreement_50,i];
        end    
        if length(tmp) >= size(class_maps,1)*30/100
            agreement_30 = [agreement_30,i];
        end   
        if length(tmp) >= size(class_maps,1)*20/100
            agreement_20 = [agreement_20,i];
        end  
        if length(tmp) >= size(class_maps,1)*10/100
            agreement_10 = [agreement_10,i];
        end   
    end
end

u_agreement_100 = unique(agreement_100);
u_agreement_90 = unique(agreement_90);
u_agreement_80 = unique(agreement_80);
u_agreement_50 = unique(agreement_50);
u_agreement_30 = unique(agreement_30);
u_agreement_20 = unique(agreement_20);
u_agreement_10 = unique(agreement_10);

for i = 1:size(class_maps,1)
    for j = i+1:size(class_maps,1)
        if isequal(class_maps(i,:),class_maps(j,:))
            str = strcat(num2str(i),'->',num2str(j));
        end
    end
end