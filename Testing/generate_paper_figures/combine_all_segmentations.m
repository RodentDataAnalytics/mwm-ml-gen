[class_map_detailed,d_points,store_d,class_map_detailed_flat] = distr_strategies_smoothing(segmentation_configs, classification_configs);
[class_map_detailed2,d_points2,store_d2,class_map_detailed_flat2] = distr_strategies_smoothing(segmentation_configs, classification_configs);
[class_map_detailed3,d_points3,store_d3,class_map_detailed_flat3] = distr_strategies_smoothing(segmentation_configs, classification_configs);

a = segmentation_configs.PARTITION;
b = segmentation_configs.PARTITION;
c = [a;b];


[distr_maps_segs, length_map, segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',0);
[distr_maps_segs2, length_map2, segments2] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',0);

remove1 = [];
for i = 1:size(distr_maps_segs2,1)
    if distr_maps_segs2(i,1) == -2;
        remove1 = [remove1;i];
    end
end
        
remove2 = [];
for i = 1:size(distr_maps_segs,1)
    if distr_maps_segs(i,1) == -2;
        remove2 = [remove2;i];
    end
end
 
remove = [];
for i = 1:size(distr_maps_segs2,1)
    if distr_maps_segs2(i,1) == -2 && distr_maps_segs(i,1) == -2
        tmp = [i,i];
        remove = [remove;tmp];
    elseif distr_maps_segs2(i,1) == -2 && distr_maps_segs(i,1) ~= -2
        tmp = [i,-1];
        remove = [remove;tmp];
    end
end
s = find(remove(:,2)==-1);

class_map = -1*ones(size(class_map_detailed_,1),size(class_map_detailed_,2));
for i = 1:size(class_map_detailed_,1)
    for j = 1:size(class_map_detailed_,2)
        if class_map_detailed2(i,j) == -1
            break;
        end
        tmp = [class_map_detailed2(i,j),class_map_detailed3(i,j),class_map_detailed_(i,j)];
        tmp_class_counter = zeros(1,8);
        for c = 1:8
            tmpc = length(find(tmp==c));
            tmp_class_counter(c) = tmpc;
        end
        
        if sum(tmp_class_counter) == 0;
            class_map(i,j) = 0;
        end
        [a,idx] = sort(tmp_class_counter,'descend');
        if a(1)==a(2)
            class_map(i,j) = 0;
        else
            class_map(i,j) = idx(1);
        end
    end
end