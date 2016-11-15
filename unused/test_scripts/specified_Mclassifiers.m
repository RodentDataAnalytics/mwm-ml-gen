Classifiers_folder = 'I:\Documents\MWMGEN\tiago_original\classification\class_1301_10388_250_07';
Output_folder = 'I:\Documents\MWMGEN\Test2';
Sample = 10;

files = dir(fullfile(Classifiers_folder,'*.mat'));

% Sort the files by number_of_clusters
nums = zeros(length(files),1);
for i = 1:length(files)
    s = strsplit(files(i).name,{'_','.'});
    n = str2double(s{5});
    nums(i) = n;
end
[val,idx] = sort(nums);
s_files = files;
for i = 1:length(files)
    s_files(i) = files(idx(i));
end

% Make an output folder
folder = fullfile(Output_folder,strcat('split_',num2str(Sample)));
if ~exist(folder,'dir')
    mkdir(folder);
end

iter = floor(length(s_files)/Sample);
index = 0;
h = waitbar(0,'Loading');
for i = 1:iter
    % Collect 'Sample' classifiers
    classifications = {};
    for j = 1:Sample
        load(fullfile(Classifiers_folder,s_files(j+index).name));
        classifications{j} = classification_configs;
    end
    index = index+Sample;
    % Merge
    [classifications, ~] = majority_rule(folder, classifications, 0);
    % Save
    classification_configs = classifications{end};
    str = sprintf('merged_%d.mat',i);
    save(fullfile(folder,str),'classification_configs');
    
    waitbar(i/iter);
end    
delete(h);
    
    
    
    
    
    
    