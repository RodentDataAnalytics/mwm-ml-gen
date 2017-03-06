ppath = 'I:\Documents\MWMGEN\tiago_original\Mclassification\class_1301_10388_250_07_10_10_mr0';
output_dir = '\\staffstore\avgoustinos\.redirect\Desktop\res';

folds = 10;
files = dir(fullfile(ppath,'*.mat'));
for i = 1:length(files)
    output_dir = fullfile(output_dir,files(i).name);
    mkdir(output_dir);
    load(fullfile(ppath,files(i).name));
    results_confusion_matrix(classification_configs,folds,output_dir);
end
