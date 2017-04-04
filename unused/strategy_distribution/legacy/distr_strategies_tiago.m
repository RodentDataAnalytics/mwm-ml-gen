function [varargout] = distr_strategies_tiago(segmentation_configs, classification_configs, varargin)
%DISTR_STRATEGIES_TIAGO computes the prefered strategy for a small time 
%window for each trajectory.
    
    %% OUTPUT
    %varargout{1} = original strategies distributions
    %varargout{2} = weights 1 strategies distributions
    %varargout{3} = computed weights strategies distributions
    %varargout{4} = final class weights
    %varargout{5} = weights before bounded (min-max)
    varargout = cell(5,1);

    %% INPUT
    % default
    sigma = 4;  
    HARD_BOUNDS = 1; % on/off bounded min/max weights
    OPTION = 2; % 1 -> weights = 1, 2 -> use classifier's resutls
    TRUE_LENGTHS = 0; %for HARD_BOUNDS it uses the true lengths to set them
    % defined
    for i = 1:length(varargin)
        if isequal(varargin{i},'sigma')
            sigma = varargin{i+1};
        elseif isequal(varargin{i},'HARD_BOUNDS')
            HARD_BOUNDS = varargin{i+1};
        elseif isequal(varargin{i},'OPTION')
            OPTION = varargin{i+1};
        elseif isequal(varargin{i},'TRUE_LENGTHS')
            TRUE_LENGTHS = varargin{i+1};
        end
    end
    
    %% INITIALIZE %%
    % Overlap
    ovl = segmentation_configs.SEGMENTATION_PROPERTIES(2);
    % Classes
    classes = unique(classification_configs.CLASSIFICATION.class_map);
    classes = classes(2:end);
    % Maximum partitions
    nbins = max(segmentation_configs.PARTITION);
    % Mapping
    [class_map, length_map, segments] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
    varargout{1} = class_map;
    % Offsets mapping
    offsets = -1.*ones(size(class_map,1),size(class_map,2));
    for i = 1:size(offsets,1)
        for j = 1:size(offsets,2)
            if ~isequal(segments{i,j},-1)
                offsets(i,j) = segments{i,j}.offset;
            else
                offsets(i,j) = -1;
            end
        end
    end

    %% COMPUTE %%
    for iter = 1:2
        if iter == 1 %run once with weights = 1 
            class_w = ones(1,length(classes));
            class_w_bk = class_w;
        elseif iter == 2 %the second time use the computed weights
            [class_w,~,Lmax_k] = computed_weights_tiago(class_map,classes,ovl);
            [class_map, length_map, ~] = form_class_distr(segmentation_configs,classification_configs,'REMOVE_DIRECT_FINDING',1);
            if HARD_BOUNDS
                class_w_bk = class_w;
                if TRUE_LENGTHS
                    class_w = hard_bounds(class_w,Lmax_k);
                else
                    class_w = hard_bounds(class_w);
                end
            end
        end
        % For each trajectory (excluding unsegmented ones)
        for i = 1:size(class_map,1)
            % Hold the score for each strategy
            class_distr_traj = ones(nbins,length(classes))*-1;
            % Find the index of the last segment of this trajectory
            endIndex = length(find(class_map(i,:) ~= -1));
            % For each segment
            for j = 1:endIndex
                wi = j; %current segment
                wf = j; %overlapped segments
                coverage = offsets(i,j) + length_map(i,j);
                % Go here until coverage <= offset of last segment
                for k = j+1:endIndex
                    if offsets(i,k) > coverage
                        wf = k-1-1;
                        break;
                    end
                end
                % Go here for the rest of the segments
                %(after coverage >= offset of last semgnent) 
                if coverage > offsets(i,endIndex)
                    wf = wi + (endIndex - j)-1;
                end
                m = (wi + wf) / 2; %mid-point
                % For the current segment until all the overlapped ones
                % after this compute the score of each strategy
                for k = wi:wf
                    if class_map(i,j) > 0
                        col = class_map(i,j);
                        %equation 2, supplementary material page 7
                        val = class_w(col)*exp(-(k-m)^2 / (2*sigma^2));
                        if class_distr_traj(k,col) == -1
                            class_distr_traj(k,col) = val;
                        else
                            class_distr_traj(k,col) = class_distr_traj(k,col) + val;
                        end
                    end
                end 
            end
            % Based on the score form the new class_map
            for j = 1:endIndex
                [val,pos] = max(class_distr_traj(j,:));
                if val > 0
                    class_map(i,j) = pos;
                else
                    class_map(i,j) = 0;
                end
                  %Good for visualization
%                 val = max(class_distr_traj(j,:));
%                 pos = ind2sub(size(class_distr_traj(j,:)),find(class_distr_traj(j,:)==val));
%                 if length(pos) > 1 ||  val <= 0
%                     class_map(i,j) = 0;
%                 else
%                     class_map(i,j) = pos;
%                 end
            end
            
        end
        % Keep the new class_map(s)
        varargout{iter+1} = class_map;
    end    
    varargout{4} = class_w;
    varargout{5} = class_w_bk;
    
    if OPTION == 1
        varargout{3} = varargout{2};
    elseif OPTION == 2;
        varargout{3} = varargout{1};
    end
end            
