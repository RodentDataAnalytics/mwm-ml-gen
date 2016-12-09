function [major_classes, full_distributions, seg_classes, class_w] = test_sigma_distr_strat(segmentation_configs, classification_configs, output_dir, varargin)
%DISTR_STRATEGIES computes the prefered strategy for a small time window
%for each trajectory.

%% OPTIONS (INPUT) %%
%-sigma: controls how many segments influence the choice of segment
%       classes over the swimming paths.
%-discard_undefined: keep/discard undefined
%-w: method of computed the weights
%-tiny_num: used for computed the full_distributions (hidden from user)
sigma = 4;
discard_undefined = 0;
%w = 'defined';
w = 'computed';
norm_method = 'off';
hard_bounds = 'on';
%tiny_num = 1e-6;
tiny_num = realmin;
min_seg = 1;

sig = 0.5:0.5:10;
h = waitbar(0,'Generating distr_strats');
for ss = 1:length(sig)
sigma = sig(ss);
    %% INITIALIZE USER INPUT %%
    for i = 1:length(varargin)
        if isequal(varargin{i},'sigma')
            sigma = varargin{i+1};
            if sigma <= 0
                sigma = 1;
            end
        elseif isequal(varargin{i},'discard_undefined')
            if isequal(varargin{i+1},1) || isequal(varargin{i+1},'on') || isequal(varargin{i+1},'ON')
                discard_undefined = 1;
            end
        elseif isequal(varargin{i},'smoothing')   
            min_seg = varargin{i+1};
            if min_seg <= 0
                min_seg = 1;
            end
        elseif isequal(varargin{i},'weights')   
            w = varargin{i+1};
        end
    end     
                      
    %% INITIALIZATION %%
    class_map = classification_configs.CLASSIFICATION.class_map;
    %segment length
    lengths = segmentation_configs.FEATURES_VALUES_SEGMENTS(:,10);
    %class slots
    nbins = max(segmentation_configs.PARTITION);
    %segment class slots
    seg_classes = zeros(1,length(class_map));
    %all classes
    classes = zeros(1,length(classification_configs.CLASSIFICATION_TAGS));
    for i = 1:length(classes)
        classes(i) = classification_configs.CLASSIFICATION_TAGS{i}{1,3};
    end
    %class weights
    class_w = zeros(1,length(classes));
    switch w
        case 'ones'
            class_w = ones(1,length(classes));
        case 'defined'  
            for i = 1:length(classes)
                class_w(i) = classification_configs.CLASSIFICATION_TAGS{i}{1,4};
            end
        case 'computed'
            class_w = computed_weights(segmentation_configs, classification_configs);           
    end   
    
    %weights normalization
    if ~isequal(norm_method,'off') && ~isequal(norm_method,'OFF') && ~isequal(norm_method,0)
        class_w = normalizations(class_w,norm_method);
    end
    %hard bounds
    if ~isequal(hard_bounds,'off') && ~isequal(hard_bounds,'OFF') && ~isequal(hard_bounds,0);
        avg_w = max(class_w)/2;
        avg_w = avg_w-1;
        avg_w = avg_w/2;
        for i = 1:length(class_w)
            if class_w(i) < avg_w
                class_w(i) = 1;
            else
                class_w(i) = max(class_w);
            end
%             if class_w(i) < 5
%                 class_w(i) = 1;
%             else
%                 class_w(i) = 10;
%             end
        end
    end
    
    %strategies distribution
    class_distr_traj = [];
    %array that shows numerically distribution values
    full_distributions = [];
    %final strategy distribution
    major_classes = [];
    %
    undef = [];
    %for matching segments to trajectory
    id = [-1, -1, -1];
    %the ith path segment, Si 
    iseg = 0;

    %% PROCESSING %%
    for i = 1:classification_configs.CLASSIFICATION.segments.count
        segment = classification_configs.CLASSIFICATION.segments.items(i);
        if ~isequal(id, segment.data_identification)
            %take the segment id
            id = segment.data_identification;
            %distribute the classes
            if ~isempty(class_distr_traj)
%                 %full distributions
%                 tmp = class_distr_traj;
%                 tmp(tmp(:) == -1) = 0;
%                 if isempty(undef) %we do not have undefined
%                     nrm = repmat(sum(tmp,2) + tiny_num, undef', 1, length(classes));
%                 else
%                     nrm = repmat(sum(tmp,2) + tiny_num, undef', 1, length(classes)-1);
%                 end
%                 nrm(class_distr_traj == -1) = 1;
%                 class_distr_traj = class_distr_traj ./ nrm;
%                 full_distributions = [full_distr, class_distr_traj];
                
                %take only the most frequent class for each bin and traj
                traj_distr = zeros(1,nbins);
                for j = 1:nbins
                    [val,pos] = max(class_distr_traj(j,:));
                    if val > 0
                        if undefined(j) > val && discard_undefined
                            traj_distr(j) = 0;
                        else
                            traj_distr(j) = pos;
                        end
                    else
                        if j > iseg
                            traj_distr(j) = -1;
                        else
                            traj_distr(j) = 0;
                        end
                    end
                end
                major_classes = [major_classes; traj_distr];
            end
            
            %exclude the undefined
            undef = find(classes == 0);
            if isempty(undef)
                class_distr_traj = ones(nbins,length(classes))*-1;
            else
                class_distr_traj = ones(nbins,length(classes)-1)*-1;
            end    
            undefined = zeros(1,nbins);
            iseg = 0;
        end
        iseg = iseg + 1;
        
        wi = iseg; %current segment
        wf = iseg; %overlapped segments
        coverage = segment.offset + lengths(i);
        for j = i+1 : classification_configs.CLASSIFICATION.segments.count
            segment_ = classification_configs.CLASSIFICATION.segments.items(j);
            if ~isequal(id,segment_.data_identification) || segment_.offset > coverage
                wf = iseg - 1 + j - i - 1;
                break;
            end
        end
        
        % mid-point
        m = (wi + wf) / 2;
        for j = wi:wf
            if class_map(i) > 0
                col = class_map(i);
                %equation 2, supplementary material page 7
                val = class_w(col)*exp(-(j-m)^2 / (2*sigma^2));
                if class_distr_traj(j,col) == -1
                    class_distr_traj(j,col) = val;
                else
                    class_distr_traj(j,col) = class_distr_traj(j,col) + val;
                end
            elseif discard_undefined
                undefined(j) = undefined(j) + 1;
            end
        end
    end
    
    %% GENERATE RESULTS %%
    if ~isempty(class_distr_traj)
        %FULL DISTRIBUTIONS
        tmp = class_distr_traj;
        tmp(tmp(:) == -1) = 0;
        if isempty(undef) %we do not have undefined
            nrm = repmat(sum(tmp,2) + tiny_num, 1, length(classes));
        else
            nrm = repmat(sum(tmp,2) + tiny_num, 1, length(classes)-1);
        end
        nrm(class_distr_traj == -1) = 1;
        full_distributions = class_distr_traj ./ nrm; 
        
        %MAJOR CLASSES
        for j = 1:nbins
            [val,pos] = max(class_distr_traj(j,:));
            if val > 0
                traj_distr(j) = pos;
            else
                if j > iseg
                    traj_distr(j) = -1;
                else
                    traj_distr(j) = 0;
                end
            end
        end
        major_classes = [major_classes; traj_distr];
        
        %Extra: remove spurious segments (or "smooth" the data)
        if min_seg > 1
            for i = 1:size(major_classes, 1)
                j = 1;
                lastc = -1;
                lasti = 0;
                while(j <= size(major_classes, 2) && major_classes(i, j) ~= -1)
                    if lastc == -1
                        lastc = major_classes(i, j);
                        lasti = j;
                    elseif major_classes(i, j) ~= lastc
                        if (j - lasti) < min_seg && lastc ~= 0                                                       
                            if lasti > 1
                                % find middle point
                                m = floor( (j + lasti) / 2);
                                major_classes(i, lasti:m) = major_classes(i, lasti - 1);                                
                                major_classes(i, m + 1:j) = major_classes(i, j);                                
                            end
                        end
                        lastc = major_classes(i, j);
                        lasti = j;
                    end                     
                    j = j + 1;
                end
            end     
        end
        
        %FINAL SEGMENTS
        %re-map distribution to the flat list of segments
        index = 1;
        partitions = segmentation_configs.PARTITION;
        partitions = partitions(partitions > 0);
        for i = 1:length(partitions)
            seg_classes(index : index + partitions(i) - 1) = major_classes(i, 1:partitions(i));
            index = index + partitions(i);
        end
    end
strat_distr = major_classes;
file = fullfile(output_dir,strcat('strat_distr',num2str(sigma),'.mat'));
save(file,'strat_distr');
waitbar(ss/length(sig));
end 
delete(h);
end