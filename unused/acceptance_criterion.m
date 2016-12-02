% Acceptance test
labels = '1301';
segments = '10388';
ppath = 'C:\Users\Avgoustinos\Documents\MWMGEN\demo_original_set_1\results';
t = {'','TT','IC','SC','FS','CR','SO','SS','ST',''};

all_scores = {};

folder = dir(ppath);
for i = 3:length(folder)
    if strfind(folder(i).name, 'Strategies-class_')
        parts = strsplit(folder(i).name,'_');
        if isequal(parts{2},labels) && isequal(parts{3},segments)
            sample = parts{6};
            iter = parts{7};
            subfolder = dir(fullfile(ppath,folder(i).name));
            
            if isnan(str2double(subfolder(3).name(2:3)))
                continue;
            else
                for j = 3:length(subfolder)
                    if strfind(subfolder(j).name, '_summary')
                        files = dir(fullfile(ppath,folder(i).name,subfolder(j).name,'*.csv'));
                        for f = 1:length(files)
                            if isequal(files(f).name,'pvalues_summary.csv')
                                csvpath = fullfile(ppath,folder(i).name,subfolder(j).name,files(f).name);
                                [num_cols, ~] = count_columns(csvpath,',');
                                fmt = repmat('%s ',[1,num_cols]);
                                fileID = fopen(csvpath);
                                data = textscan(fileID,fmt,'CollectOutput',1,'Delimiter',',');
                                data = data{1};
                                fclose(fileID);
                                
                                strats = {};
                                scores = [];
                                for ii = 2:size(data,1)
                                    if ~isempty(data{i,1})
                                        strats = [strats,data{ii,1}];
                                        scores = [scores,str2double(data{ii,2})];
                                    end
                                end
                                
                                collect = {sample, iter, scores};
                                all_scores = [all_scores ; collect];
                            end
                        end
                    end
                end
            end
        end
    end 
end
      
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;

fig = figure;
hold on
h1 = fill([0 8 8 0],[-1 -1 40 40],[1 0.8 1]);
h2 = fill([0 8 8 0],[40 40 70 70],[1 1 0.6]);
% plot lines
plot([0,8],[70,70],'color','red','LineStyle','-','LineWidth',1.5);
plot([0,8],[40,40],'color','red','LineStyle','-','LineWidth',1.5);
 
% plot data
for i = 1:size(all_scores,1)
    percentages = 100 * all_scores{i,3} ./str2double(all_scores{i,2});
    plot(percentages,'k*');
end

faxis = findobj(fig,'type','axes');
set(faxis, 'XTickLabel', t, 'FontSize', FontSize, 'FontName', FontName);
set(faxis, 'LineWidth', LineWidth, 'FontSize', FontSize, 'FontName', FontName);
ylim([-1 101]);
hold off
