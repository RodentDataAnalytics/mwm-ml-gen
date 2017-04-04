function [ nums, idx ] = sort_classifiers(class_list)
%SORT_CLASSIFIERS sorts the classifiers by number of clusters
    
    nums = zeros(1,length(class_list));
    for i = 1:length(nums)
        n = strsplit(class_list{i},{'_','.mat'});
        nums(i) = str2double(n{5});
    end
    [nums,idx] = sort(nums);
    
end

