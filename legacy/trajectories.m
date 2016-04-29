classdef trajectories < handle
    %TRAJECTORIES Summary of this class goes here
    %   Detailed explanation goes here
    properties(GetAccess = 'public', SetAccess = 'public')
        % use two-phase clustering
        clustering_two_phase = 1;
        % force use of must link constraints in the first phase
        clustering_must_link = 0;
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        items = [];        
        parent = []; % parent set of trajectories (if these are the segments)
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        hash_ = -1;
        trajhash_ = [];
        partitions_ = [];       
        parent_mapping_ = [];
        segmented_idx_ = [];
        segmented_map_ = [];        
    end
    
    methods
        % constructor
        function inst = trajectories(traj)
            inst.items = traj;            
        end
               
        function sz = count(obj)
            sz = length(obj.items);            
        end          
        
        function obj2 = append(obj, x)
            obj2 = trajectories([]);    
            if isa(x, 'trajectory')
                obj2.items = [obj.items, x];                            
            elseif isa(x, 'trajectories')
                obj2.items = [obj.items, x.items];                
            else
                error('Ops');
            end
        end    
        
        function idx = index_of(obj, set, trial, track, off, len, true_len)
            if isempty(obj.trajhash_ )
                % compute hashes of trajectories and add them to a hashtable 
                a = zeros(1,length(obj.items));
                for i = 1:length(obj.items)
                    a(i) = trajectory.compute_hash(obj.items(i).set, obj.items(i).session, obj.items(i).track, obj.items(i).offset, true_len(i));
                end    
                obj.trajhash_ = containers.Map(a, 1:obj.count);
            end
            
            hash = trajectory.compute_hash(set, trial, track, off, len);
            % do we have it?
            if obj.trajhash_.isKey(hash)
                idx = obj.trajhash_(hash);
            else
                idx = -1;
            end            
        end            
        
        function out = hash_value(obj)            
            if obj.hash_ == -1                                          
                % compute hash
                if obj.count == 0
                    obj.hash_ = 0;
                else
                    obj.hash_ = obj.items(1).hash_value;
                    for i = 2:obj.count                        
                        obj.hash_ = hash_combine(obj.hash_, obj.items(i).hash_value);
                    end
                end                
            end
            out = obj.hash_;
        end
        
        function [ segments, partition, cum_partitions, fn ] = partition(obj, cache_dir, nmin, func, varargin)
        %   SEGMENT(LSEG, OVLP) breaks all trajectories into segments
        %   of length LEN and overlap OVL (given in %)   
        %   returns an array of trajectory segments
            id = 0;
            id = hash_combine (id, hash_value(varargin) );
            fn = fullfile(cache_dir, ['segments_', num2str(id), '.mat']);
            if exist(fn, 'file')            
                load(fn);  
                segments = seg;
            else                                          
                fprintf('Segmenting trajectories... ');
                % construct new object
                segments = trajectories([]);
                partition = zeros(1, obj.count);
                cum_partitions = zeros(1, obj.count);
                p = 1;
                off = 0;
                func = str2func(func); %segmentation function
                for i = 1:obj.count                
                    newseg = obj.items(i).partition(func,varargin{:});

                    if newseg.count >= nmin                    
                        segments = segments.append(newseg);
                        partition(i) = newseg.count;
                        cum_partitions(i) = off;
                        off = off + newseg.count;
                    else
                        cum_partitions(i) = off;
                    end

                    if segments.count > p*1000
                        fprintf('%d ', segments.count);
                        p = p + 1; 
                    end  
                end
                segments.partitions_ = partition;
                segments.parent = obj;

                fprintf(': %d segments created.\n', segments.count);
                % cache it for next time
                seg = segments;
                save(fn, 'seg', 'partition', 'cum_partitions');
            end
        end
        
        function out = partitions(inst)
            if inst.count > 0 && isempty(inst.partitions_)
                id = [-1, -1, -1];
                n = 0;
                for i = 1:inst.count    
                    if ~isequal(id, inst.items(i).data_identification)
                        if n > 0
                           inst.partitions_ = [inst.partitions_, n];
                        end
                        id = inst.items(i).data_identification;                            
                    end
                    n = n + 1;
                end
                if n > 0
                    inst.partitions_ = [inst.partitions_, n];
                end                        
            end
            out = inst.partitions_;
        end
        
        function out = parent_mapping(inst)
            if inst.count > 0 && ~isempty(inst.partitions) && isempty(inst.parent_mapping_)
                inst.parent_mapping_ = zeros(1, inst.count);
                idx = 0;
                tmp = inst.partitions();
                for i = 1:length(tmp)
                    for j = 1:tmp(i);
                        idx = idx + 1;                        
                        inst.parent_mapping_(idx) = i;
                    end
                end                                                
            end
            out = inst.parent_mapping_;
        end
        
        function out = segmented_index(inst)
            if inst.count > 0 && ~isempty(inst.partitions) && isempty(inst.segmented_idx_)
                inst.segmented_idx_ = find(inst.partitions > 0);                
            end
            out = inst.segmented_idx_;
        end
        
        function out = segmented_mapping(inst)
            if inst.count > 0 && ~isempty(inst.partitions) && isempty(inst.segmented_map_)                
                inst.segmented_map_ = zeros(1, length(inst.partitions));
                inst.segmented_map_(inst.partitions > 0) = 1:sum(inst.partitions > 0);
            end
            out = inst.segmented_map_;
        end                
     
        function featval = compute_features_pca(obj, feat, nfeat)
            featval = obj.compute_features(feat);
            coeff = pca(featval);
                
            featval = featval*coeff(:, 1:nfeat);                
        end
        
        function featval = compute_features(obj, feat, varargin)
            %COMPUTE_FEATURES Computes feature values for each trajectory/segment. Returns a vector of
            %   features.                        
            [progress] = process_options(varargin, ...
                               'ProgressCallback', []);
                           
            featval = zeros(obj.count, length(feat));            
            for idx = 1:length(feat)
                id = feat(idx).hash_value;
                desc = feat(idx).description;
                % check if we already have the values for this feature cached
                key = hash_combine(obj.hash_value, id);
            
                fn = fullfile(globals.CACHE_DIRECTORY, ['features_' num2str(key) '.mat']);
                if exist(fn, 'file')
                    load(fn);                    
                    featval(:, idx) = tmp;
                else                    
                    % not cached - compute it we shall
                    fprintf('\nComputing ''%s'' feature values for %d trajectories/segments...', desc, obj.count);
                    
                    q = floor(obj.count / 1000);
                    fprintf('0.0% ');                                        
                
                    for i = 1:obj.count
                        % compute and append feature values for each segment
                        featval(i, idx) = obj.items(i).compute_feature(feat(idx));

                        if mod(i, q) == 0
                            val = 100.*i/obj.count;
                            if val < 10.
                                fprintf('\b\b\b\b\b%02.1f%% ', val);
                            else
                                fprintf('\b\b\b\b\b%04.1f%%', val);
                            end    
                            
                            if ~isempty(progress)
                                mess = sprintf('[%d/%d] Computing ''%s'' feature values', idx, length(feat), desc);
                                if progress(mess, i/obj.count)
                                    error('Operation cancelled');
                                end                                
                            end
                        end                       
                    end
                    fprintf('\b\b\b\b\bDone.\n');
                    
                    % save it
                    tmp = featval(:, idx);
                    save(fn, 'tmp');                    
                end                                                
            end                                            
        end
                 
        function [map, idx, tag_map] = match_tags(obj, labels, tags, segments_true_length)
            % start with an empty set
            map = zeros(obj.count, length(tags));
            idx = repmat(-1, 1, length(labels));
                                
            % for each label
            for i = 1:size(labels, 1)
                % see if we have this trajectory/segment
                id = labels{i, 1};
                if isempty(id)
                    continue;
                end

                pos = obj.index_of(id(1), id(2), id(3), id(4), id(5), segments_true_length);
                if pos ~= -1
                    idx(i) = pos;
                    % add labels        
                    tmp = labels{i, 2};
                    for k = 1:length(tmp)
                        map(pos, tmp(k)) = 1;                        
                    end                    
                end                
            end 
            
            tag_map = 1:length(tags);
        end                   
                              
        function res = classifier(inst, labels_data, tags, segments_true_length)
                       
            [labels_map, labels_idx] = inst.match_tags(labels_data, tags, segments_true_length);
            
            % add the 'undefined' tag index
            undef_tag_idx = tag.tag_position(tags, 'UD');
            if undef_tag_idx > 0
                tags = tags([1:undef_tag_idx - 1, (undef_tag_idx + 1):length(tags)]);          
                tag_new_idx = [1:undef_tag_idx, undef_tag_idx:length(tags)];
                tag_new_idx(undef_tag_idx) = 0;
            else
                tag_new_idx = 1:length(tags);
            end
            
            assert(size(labels_map, 1) == inst.count);
            labels = repmat({-1}, 1, inst.count);
            for i = 1:inst.count
                class = find(labels_map(i, :) == 1);
                if ~isempty(class)
                    % for the 'undefined' class set label idx to zero..
                    if class(1) == undef_tag_idx
                        labels{i} = 0;
                    else
                        % rebase all tags after the undefined index
                        labels{i} = arrayfun( @(x) tag_new_idx(x), class);
                    end                                       
                end
            end
                         
            global g_trajectories;            
            unmatched = find(labels_idx == -1);
            extra_lbl = {};
            extra_feat = []; 
            extra_ids = [];
                            
            res = semisupervised_clustering(inst, [extra_feat; inst.compute_features(feat)], [extra_lbl, labels], tags, length(extra_lbl));            
        end   
        
        
        function [mapping] = match_segments(inst, other_seg, varargin)
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [seg_dist, tolerance, len_tolerance] = process_options(varargin, ...
                'SegmentDistance', 0, 'Tolerance', 20, 'LengthTolerance', 0 ...
            );            
            
            if len_tolerance == 0
                len_tolerance = tolerance;
            end
            mapping = ones(1, inst.count)*-1;
            idx = 1;
            if other_seg.count > inst.count            
                for i = 1:other_seg.count
                    while( ~isequal(inst.items(idx).data_identification, other_seg.items(i).data_identification) || ...
                             inst.items(idx).offset < other_seg.items(i).offset - seg_dist - tolerance)                      
                        idx = idx + 1;                    
                        if idx == inst.count
                            break;
                        end                    
                    end
                    % all right now try to match the offset
                    if abs(inst.items(idx).offset - other_seg.items(i).offset) < seg_dist + tolerance && ...
                       abs(varargin{1,3}(idx) - varargin{1,4}(i)) < len_tolerance
                        % we have a match!
                        mapping(idx) = i;
                        idx = idx + 1;                    
                    end               
                    if idx == inst.count
                        break;
                    end
                end
            else
                for i = 1:inst.count                    
                    if( ~isequal(other_seg.items(idx).data_identification, inst.items(i).data_identification))
                       continue;
                    end    
                    % test if we overshoot the segment                   
                    loop = 0;
                    while (other_seg.items(idx).offset < inst.items(i).offset - seg_dist - tolerance)                        
                        if ~isequal(other_seg.items(idx).data_identification, inst.items(i).data_identification)
                            loop = 1;
                            break;
                        end
                        idx = idx + 1;                    
                        if idx == other_seg.count
                            break;
                        end                    
                    end
                    if loop
                        continue;
                    end
                    % all right now try to match the offset
                    if abs(inst.items(i).offset - seg_dist - other_seg.items(idx).offset) < tolerance && ...
                       abs(varargin{1,3}(i) - varargin{1,4}(idx)) < len_tolerance
                        % we have a match!
                        mapping(i) = idx;
                        idx = idx + 1;                  
                    end               
                    if idx == other_seg.count
                        break;
                    end
                end
            end
        end                     
    end        
end