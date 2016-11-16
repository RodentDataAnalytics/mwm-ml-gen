function error = majority_rule_init(output_folder, class_folders, sample, threshold, iterations, varargin)
%MAJORITY_RULE_INIT runs the majority rule a number of times with the given
%options.

    h = waitbar(0,'Initializing merging...','Name','Generating classifiers');
    error = 1;
    if ~exist(output_folder,'dir')
        errordlg('The output folder specified does not exist','Error');
        delete(h);
        return;
    end
    
    % Sample: always take equal number of classifiers from each group
    new_sample = sample;
    for i = 1:length(class_folders)
        mat_files = dir(fullfile(char(class_folders{i}),'*.mat'));
        if length(mat_files) < new_sample
            new_sample = length(mat_files);
        end
    end
    if new_sample == 0
        errordlg('A group(s) of classifiers contains 0 classifiers','Error');
        delete(h);
        return;
    end
    if new_sample ~= sample
        str = num2str(new_sample);
        warndlg(strcat('A group(s) contains less classifiers than the sample specified. The new sample value is set to ',str));
    end
    
    % Classifiers: pick all the .mat files of the specified folders
    files = cell(1,length(class_folders));
    data = cell(1,length(class_folders));
    for i = 1:length(class_folders)
        files{i} = dir(fullfile(char(class_folders{i}),'*.mat'));
        data{i} = 1:length(files{i});
    end

    % Run the majority rule ITERATIONS times and each time pick another
    % random sample from the classifiers pool.
    str_ = strcat('Iteration:','1','/',num2str(iterations));
    waitbar(0,h,str_);
    for i = 1:iterations
        classifications = {};
        clusters = [];
        for k = 1:length(class_folders)
            x = randsample(data{k},new_sample);
            classifications_ = cell(1,length(new_sample));
            clusters_ = 1:length(new_sample);
            for j = 1:length(x)
                clear classification_configs;
                file_path = fullfile(class_folders{k},files{k}(x(j)).name);
                load(file_path)
                classifications_{j} = classification_configs;
                clusters_(j) = classification_configs.DEFAULT_NUMBER_OF_CLUSTERS;
            end
            classifications = [classifications,classifications_];
            clusters = [clusters,clusters_];
        end    
        if ~isempty(varargin) %multiple classifiers
            [classifications, ~] = majority_rule(output_folder, classifications, threshold, varargin{:});
        else                    
            [classifications, ~] = majority_rule(output_folder, classifications, threshold);
        end    
        if classifications{1} == 0
            close(h)
            errordlg('Error executing the majority rule','Error'); 
            return
        end
        str_ = strcat('Iteration:',num2str(i),'/',num2str(iterations));
        waitbar(i/iterations,h,str_);
        % save
        classification_configs = classifications{end};
        str = sprintf('merged_%d.mat',i);
        save(fullfile(output_folder,str),'classification_configs');
    end   
    % Create a CSV-file for the undecided segments
    find_similar_unlabelled(output_folder);
    close(h)
    error = 0;
end

