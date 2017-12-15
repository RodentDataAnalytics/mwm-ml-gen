classdef trajectories < handle
    %TRAJECTORIES Summary of this class goes here
    %   Detailed explanation goes here
    properties(GetAccess = 'public', SetAccess = 'public')
        % use two-phase clustering
        clustering_two_phase = 1;
        % force use of must link constraints in the first phase
        clustering_must_link = 0;
    end
    
    properties(GetAccess = 'public', SetAccess = 'public')
        items = [];        
        parent = []; % parent set of trajectories (if these are the segments)
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
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
        
        function [ segments, partition, cum_partitions] = partition(obj, nmin, func, varargin)
        %   SEGMENT(LSEG, OVLP) breaks all trajectories into segments
        %   of length LEN and overlap OVL (given in %)   
        %   returns an array of trajectory segments      
            %h = waitbar(0,'Segmenting trajectories...');
            %fprintf('Segmenting trajectories... ');
            % construct new object
            segments = trajectories([]);
            partition = zeros(1, obj.count);
            cum_partitions = zeros(1, obj.count);
            p = 1;
            off = 0;
            func = str2func(func); %segmentation function
            for i = 1:obj.count       
                newseg = obj.items(i).partition(func,varargin{:},i);
                if newseg.count >= nmin                    
                    segments = segments.append(newseg);
                    partition(i) = newseg.count;
                    cum_partitions(i) = off;
                    off = off + newseg.count;
                else
                    cum_partitions(i) = off;
                end
                if segments.count > p*1000
                    %fprintf('%d ', segments.count);
                    p = p + 1; 
                end  
                %waitbar(i/obj.count);
            end
            %delete(h);
            segments.partitions_ = partition;
            segments.parent = obj;
            %fprintf(': %d segments created.\n', segments.count);
        end
        
        function out = partitions(inst)
            if inst.count > 0 && isempty(inst.partitions_)
                id = [-1, -1, -1, -1, -1];
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
        
        function [mapping] = match_segments(inst, other_seg, feat_len_1, feat_len, varargin)
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
                    % all right now try to match the offset;
                    if abs(inst.items(idx).offset - other_seg.items(i).offset) < seg_dist + tolerance && ...
                        abs(feat_len_1(i,10) - feat_len(idx,10)) < len_tolerance
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
                       abs(feat_len_1(i,10) - feat_len(idx,10)) < len_tolerance
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