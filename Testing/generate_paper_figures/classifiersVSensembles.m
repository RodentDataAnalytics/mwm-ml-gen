ppath = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1';

output_dir = fullfile(ppath,'results');
cpath = dir(fullfile(ppath,'classification'));
bcpath = dir(fullfile(ppath,'Mclassification'));
spath = dir(fullfile(ppath,'segmentation','*.mat'));

for z = 1:2 % classifiers, smoothing
for i = 3:length(cpath)
    bcfiles = [];
    idx = 0;
    cfiles = dir(fullfile(ppath,'classification',cpath(i).name,'*.mat'));
    tmp1 = strsplit(cpath(i).name,'_');
    for j = 3:length(bcpath)
        tmp2 = strsplit(bcpath(j).name,'_');
        if isequal(tmp1{2},tmp2{2}) && isequal(tmp1{3},tmp2{3}) &&...
               isequal(tmp1{4},tmp2{4}) && isequal(tmp1{5},tmp2{5})
            bcfiles = dir(fullfile(ppath,'Mclassification',bcpath(j).name,'*.mat'));
            idx = j;
            break;
        end
    end
    for j = 1:length(spath)
        tmp2 = strsplit(spath(j).name,'_');
        if isequal(tmp1{3},tmp2{3}) && isequal(tmp1{4},tmp2{4})
            load(fullfile(ppath,'segmentation',spath(j).name));
            break;
        end
    end    
    if isempty(bcfiles)
        continue;
    end

    % SIMPLE CLASSIFIERS
    class_maps = [];
    for j = 1:length(cfiles)
        load(fullfile(ppath,'classification',cpath(i).name,cfiles(j).name));
        cmaps = classification_configs.CLASSIFICATION.class_map;
        if z == 2
            [~,~,~,cmaps] = distr_strategies_smoothing(segmentation_configs, classification_configs);
        end
        class_maps = [class_maps;cmaps];
    end
    res = [];
    res_all = [];
    classes = unique(class_maps);
    for j = 1:size(class_maps,1)
        for k = 1:length(classes)
            tmp = length(find(class_maps(j,:)==classes(k)));
            tmp = 100*tmp/size(class_maps,2);
            res = [res,tmp];
        end
        res_all = [res_all;res];
        res = [];
    end
    
    % ENSEMBLES
    ensemble_class_maps = [];
    for j = 1:length(bcfiles)
        load(fullfile(ppath,'Mclassification',bcpath(idx).name,bcfiles(j).name));
        cmaps = classification_configs.CLASSIFICATION.class_map;
        if z == 2
            [~,~,~,cmaps] = distr_strategies_smoothing(segmentation_configs, classification_configs);
        end        
        ensemble_class_maps = [ensemble_class_maps;cmaps];
    end
    res = [];
    ensemble_res_all = [];
    classes = unique(ensemble_class_maps);
    for j = 1:size(ensemble_class_maps,1)
        for k = 1:length(classes)
            tmp = length(find(ensemble_class_maps(j,:)==classes(k)));
            tmp = 100*tmp/size(ensemble_class_maps,2);
            res = [res,tmp];
        end
        ensemble_res_all = [ensemble_res_all;res];
        res = [];
    end

    % Results
    x = [];
    g = [];
    c1 = 1;
    c2 = 2;
    for j = 1:size(ensemble_res_all,2)
        x = [x;res_all(:,j);ensemble_res_all(:,j)];
        g = [g;c1*ones(length(res_all(:,j)),1);c2*ones(length(ensemble_res_all(:,j)),1)];
        c1 = c2+1;
        c2 = c1+1;
    end
    pos = 1;
    for j = 2:18
        if mod(i,2) == 0 %even
            pos = [pos,pos(j-1)+0.02];
        else
            pos = [pos,pos(j-1)+0.07];
        end
    end
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    f = figure;
    boxplot(x,g,'positions', pos, 'colors', [0 0 0]);
    str = {'UCS','TT','IC','SC','FS','CR','SO','SS','ST'};
    faxis = findobj(f,'type','axes'); 
    % Box color
    h = findobj(f,'Tag','Box');
    for j=1:2:length(h)
         patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
    end
    % Median
    h = findobj(faxis, 'Tag', 'Median');
    for j=1:2:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.65 .65 .65], 'LineWidth', 2);
    end
    for j=2:2:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.65 .65 .65], 'LineWidth', 2);
    end
    % Outliers
    h = findobj(faxis, 'Tag', 'Outliers');
    for j=1:length(h)
        set(h(j), 'MarkerEdgeColor', [0 0 0]);
    end      
    set(faxis, 'XTick', (pos(1:2:2*length(str) - 1) + pos(2:2:2*length(str))) / 2, 'XTickLabel', str, 'FontSize', FontSize, 'FontName', FontName);
    xlabel('Classes', 'FontSize', FontSize, 'FontName', FontName);  
    ylabel('percentage of segments', 'FontSize', FontSize, 'FontName', FontName); 
    %Overall
    set(f, 'Color', 'w');
    box off;  
    set(f,'papersize',[8,8], 'paperposition',[0,0,8,8]);
    %Export and delete
    export_figure(f, output_dir, sprintf('z%d_comp_simple_ensemble_%s_%s_%s_%s',z,tmp1{2},tmp1{3},tmp1{4},tmp1{5}), Export, ExportStyle);
    delete(f);
end
end

