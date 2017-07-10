ppath = 'D:\Avgoustinos\Documents\MWMGEN\demo_original_set_1';
[~,tags] = parse_tags(fullfile(ppath,'settings','tags.txt'));

% Get segmentation_configs file
[fname, pname] = uigetfile({'*.mat','MAT-file (*.mat)'},'Select segmentation file',fullfile(ppath,'segmentation'));
if isequal(pname,0) || isequal(fname,0)
    return
end
try
    load(strcat(pname,fname));
    if ~exist('segmentation_configs','var')
        errordlg('Error loading segmentation file','Error');
        return;
    end
catch
    errordlg('Error loading segmentation file','Error');
    return;
end
% Get pics folder
dname = uigetdir(ppath,'Select folder');
if isequal(dname,0)
    return
end
mclassification = strcat(pname,fname); 
% Define output file name and path 
[fname, pname] = uiputfile('*.csv','Output File');
if isequal(pname,0)
    return
end

ext = {'.jpg','.jpeg','.pdf'};

sfolders = dir(dname);
table = {};
hold = [];

for i = 3:length(sfolders)
    if ~sfolders(i).isdir
        continue;
    end
    for e = 1:length(ext)
        files = dir(fullfile(dname,sfolders(i).name,strcat('*',ext{e})));
        if isempty(files)
            continue;
        else
            break;
        end
    end

    e = ext{e};
    n = sfolders(i).name;
    tmp = 1;
    for t = 2:size(tags,1)
        if isequal(tags{t,1},n)
            if isequal(tags{t,9},'public') || isequal(tags{t,9},'segment')
                tmp = 0;
                break;
            end
        end
    end
    if tmp
        continue;
    end
    
    for j = 1:length(files)
        %tmp = strsplit(files(j).name,{n,e});
        tmp = strsplit(files(j).name,{'traj','seg',e});
        traj = str2double(tmp{2});
        seg = str2double(tmp{3});
        if isnan(traj) || isnan(seg)
            tmp = [i,j];
            hold = [hold;tmp];
            continue;
        end
        indexes = find_segs_of_traj(segmentation_configs.SEGMENTS,traj);
        tmp = {indexes(seg) , n};
        table = [table ; tmp]; 
    end    
end

VariableNames = {};
VariableNames{1} = 'Segment';
for i = 2:size(tags)+1
	VariableNames{i} = strcat('label',num2str(i-1));
end
labels = table;
labels{1,size(VariableNames,2)} = [];
labels = [VariableNames;labels];
labels = cell2table(labels);
writetable(labels,strcat(pname,fname),'WriteVariableNames',0);