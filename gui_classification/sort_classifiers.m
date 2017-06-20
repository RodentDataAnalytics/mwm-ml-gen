function [ nums, idx ] = sort_classifiers(class_list)
%SORT_CLASSIFIERS sorts the classifiers by number of clusters
    
    if iscell(class_list)
        nums = zeros(length(class_list),1);
        for i = 1:length(nums)
            n = strsplit(class_list{i},{'_','.mat'});
			if length(n) > 3
				nums(i) = str2double(n{5}); %class
			else
				nums(i) = str2double(n{2}); %Mclass
			end
        end
        [nums,idx] = sort(nums);
        
    elseif isstruct(class_list)
        nums = zeros(length(class_list),1);
        for i = 1:length(nums)
            n = strsplit(class_list(i).name,{'_','.mat'});
			if length(n) > 3
				nums(i) = str2double(n{5}); %class
			else
				nums(i) = str2double(n{2}); %Mclass
			end
        end
        [nums,idx] = sort(nums);         
    end
end

