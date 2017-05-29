function varargout = results_strategies_transition_prob(segmentation_configs,classification_configs,groups,figures,output_dir,varargin)
% Transition probabilities of strategies within trials for two groups of
% N animals. Rows and columns indicate the starting and ending strategies 
% respectively. Row values are normalised.
    
    AVERAGE = 0;
    DISTRIBUTION = 3;
    SCRIPTS = 1;
    DISPLAY = 1;
    
    for i = 1:length(varargin)
        if isequal(varargin{i},'AVERAGE')
            AVERAGE = varargin{i+1};
        elseif isequal(varargin{i},'DISTRIBUTION')
            DISTRIBUTION = varargin{i+1};
        elseif isequal(varargin{i},'SCRIPTS')
            SCRIPTS = varargin{i+1};
        elseif isequal(varargin{i},'DISPLAY')
            SCRIPTS = varargin{i+1};            
        end
    end
    
    [~,trans_prob1, trans_prob2] = animal_transitions(segmentation_configs,classification_configs,'PROBABILITIES',groups,varargin{:});
    
    % save to txt and return varargout
    segments_classification = classification_configs.CLASSIFICATION;
    fn2 = fullfile(output_dir, 'transition_probabilities.txt');
    fileID = fopen(fn2,'wt');
    for i = 1:segments_classification.nclasses
        fprintf(fileID,'%d. %s\n', i, segments_classification.classes{1,i}{1,2});
    end
    
    fprintf(fileID, '\n');
    if length(groups) ~= 1
        for i=1:size(trans_prob1,1)
            fprintf(fileID, '%6.4f ', trans_prob1(i,:));
            fprintf(fileID, '\n');
        end
        fprintf(fileID, '\n');
        for i=1:size(trans_prob2,1)
            fprintf(fileID, '%6.4f ', trans_prob2(i,:));
            fprintf(fileID, '\n');
        end    
        varargout{1} = trans_prob1;
        varargout{2} = trans_prob2;
    else
        for i=1:size(trans_prob1,1)
            fprintf(fileID, '%6.4f ', trans_prob1(i,:));
            fprintf(fileID, '\n');
        end
        varargout{1} = trans_prob1;
    end   
    fclose(fileID);  
end

