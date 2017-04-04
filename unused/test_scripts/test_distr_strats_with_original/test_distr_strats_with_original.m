%% Test distr_strats %%
% SEGMENTATION: 300-07

folder_name = uigetdir('','Select test folder');
load(fullfile(folder_name,'my_new_res.mat'));
          
%% Weights == 1
load(fullfile(folder_name,'class_map_2.mat'));
for i=1:size(major_classes,1)
    for j = 1:size(major_classes,2)
        if major_classes(i,j)~=zzz{2}(i,j)
            fprintf('i=%d,j=%d\n',i,j)
        end
    end
end
fprintf('ONES END\n');
%i=316,j=2
%i=555,j=9

%% Weights == computed
load(fullfile(folder_name,'class_map_3.mat'));
for i=1:size(major_classes,1)
    for j = 1:size(major_classes,2)
        if major_classes(i,j)~=zzz{3}(i,j)
            fprintf('i=%d,j=%d\n',i,j)
        end
    end
end
fprintf('COMPUTED END\n');
%i=555,j=7
%i=555,j=9
