%% MAJOR PROCEDURES:
% No smoothing: generate the results based on classification.
% Smoothing: generate the results based on classification and apply filter.

% MINOR PROCEDURES:
% 1. Generate classifiers, take the ones below e% validation error, merge
%    them all and see the results.
% 2. Generate classifiers, take the ones below e% validation error, and
%    generate the confidence intervals.
% 3. Generate classifiers, take the ones below e% validation error, pick
%    samples of s for i times and generate the confidence intervals of the
%    boosted classifiers.

% SMOOTHING:
% If R equals the arena radius:
% Interval length = 0.25R , 0.5R , 0.75R , R , 1.25R , 1.5R , 1.75R , 2R
% Sigma           = 0.25R , 0.5R , 0.75R , R , 1.25R , 1.5R , 1.75R , 2R

%% SETTING UP:

% Project folder path:
PROJECT_PATH = zzz;
% Project folder path:
OUTPUT_PATH = zzz;

% Scenarios:
NO_SMOOTHING = 0;
SMOOTHING = 0;

PROCEDURE_1 = 0;
VALIDATION_ERROR_1 = [5,6,7];

PROCEDURE_2 = 0;
VALIDATION_ERROR_2 = [5,6,7];

PROCEDURE_3 = 0;
VALIDATION_ERROR_3 = [5,6,7];
SAMPLE = [5,7,9,15];
ITERATE = [15,20,25];

INTERVAL_LENGTH = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];
SIGMA = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

%% MAKE OUTPUT FOLDER TREE:
path1 = MAKE_OUTPUT_FOLDER_TREE(OUTPUT_PATH,1);

% No Smoothing
if NO_SMOOTHING
    path2 = MAKE_OUTPUT_FOLDER_TREE(path1,2);
end

if SMOOTHING
    path2 = MAKE_OUTPUT_FOLDER_TREE(rpath,-2);
end

SEGMENTATIONS = dir(fullfile(PROJECT_PATH,'segmentation'));
for SEG = i:length(SEGMENTATIONS)
    load(fullfile(PROJECT_PATH,'segmentation',SEGMENTATIONS(i).name));
    str = strsplit(SEGMENTATIONS(i).name,{'_','.mat'});
    
end