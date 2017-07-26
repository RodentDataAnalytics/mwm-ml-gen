function error = majority_rule_init(segmentation_configs, output_folder, class_folder, sample, threshold, iterations, varargin)
%MAJORITY_RULE_INIT runs the majority rule a number of times with the given
%options.

    WAITBAR = 1;
    CLUSTERS = 0;
    REPORT = 1;
    SUMMARY = 1;

    for i = 1:length(varargin)
        if isequal(varargin{i},'WAITBAR')
            WAITBAR = varargin{i+1};
        elseif isequal(varargin{i},'CLUSTERS')
            CLUSTERS = 1;
            clusters = varargin{i+1};
        elseif isequal(varargin{i},'SUMMARY')
            SUMMARY = varargin{i+1};
        elseif isequal(varargin{i},'REPORT')
            REPORT = varargin{i+1};            
        end
    end

    if ~REPORT
        SUMMARY = 0;
    end
    
    % Check if folder exists
    if WAITBAR
        h = waitbar(0,'Initializing merging...','Name','Generating classifiers');
    end
    error = 1;
    if ~exist(output_folder,'dir')
        error_messages(13);
        if WAITBAR
            delete(h);
        end
        return;
    end
    
    % Classifiers: pick all the .mat files of the specified folder
    files = dir(fullfile(class_folder,'*.mat'));
    if length(files) == 0
        error_messages(14);
        return;
    elseif length(files) <= sample
        iterations = 1;
        sample = length(files);
    end
    % Keep only the name and sort by name
    [num,idx] = sort_classifiers(files);
    f = cell(1,length(idx));
    for i = 1:length(files);
        f{i} = files(idx(i)).name;  
    end
    
    % Pick only the selected classifiers
    if CLUSTERS
        clusters = sort(clusters);
        files = cell(1,length(clusters));
        for i = 1:length(clusters)
            idx = find(num == clusters(i));
            try
            files{i} = f{idx};
            catch
                a=1;
            end
        end     
        f = files;
    end

    % Run the majority rule ITERATIONS times and each time pick another
    % random sample from the classifiers pool.
    if WAITBAR
        str_ = strcat('Iteration:','1','/',num2str(iterations));
        waitbar(0,h,str_);
    end
    tmp = 1:length(f);
    for i = 1:iterations
        %pick random sample of classifiers
        x = randsample(tmp,sample);
        x = sort(x);
        classifications = cell(1,length(x));
        for j = 1:length(x)
            try
                load(fullfile(class_folder,f{x(j)}));
            catch
                error_messages(15);
            end 
            classifications{j} = classification_configs;   
            clear classification_configs;
        end
        %execute majority voting
        [classifications, ~] = majority_rule(output_folder, classifications, threshold);
        if classifications{1} == 0
            if WAITBAR
                delete(h);
            end
            error_messages(16); 
            return
        end   
        %save
        classification_configs = classifications{end};
        str = sprintf('merged_%d.mat',i);
        save(fullfile(output_folder,str),'classification_configs');
        if WAITBAR
            str_ = strcat('Iteration:',num2str(i),'/',num2str(iterations));
            waitbar(i/iterations,h,str_)
        end
    end
    if SUMMARY
        % Create a CSV-file for the undecided segments
        find_similar_unlabelled(segmentation_configs,output_folder);
    end    
    if WAITBAR
        delete(h)
    end
    error = 0;    
end

