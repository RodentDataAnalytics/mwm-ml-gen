classdef clustering_cv_results < handle
    %CLUSTERING_CV_RESULTS
    %   Stores results of a clustering cross-validation
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        count = 0;
        % results of each sub-clustering
        results = [];        
    end
    
    methods
        function inst = clustering_cv_results(res)            
            inst.results = res;            
            inst.count = length(res);
        end
        
        function compress(inst)            
            for i = 1:length(inst.results)
                inst.results(i).compress;
            end            
        end        
        
        function res = remap_clusters(inst, varargin)
            tmp = [];
            for i = 1:inst.count
                tmp = [tmp, inst.results(i).remap_clusters(varargin{:})];
            end
            res = clustering_cv_results( tmp );
        end
        
        function append(inst, other)
            inst.results = [inst.results, other.results];
            inst.count = length(inst.results);
        end
        
        function res = nerrors(inst)
            res = arrayfun( @(r) r.nerrors, inst.results);
        end
        
        function res = punknown(inst)
            res = arrayfun( @(r) r.punknown, inst.results);
        end
        
        function res = nclusters(inst)
            res = arrayfun( @(r) r.nclusters, inst.results);
        end

        function res = nconstraints(inst)
            res = arrayfun( @(r) r.nconstraints(1), inst.results);
        end
        
        function res = perrors(inst)
            res = arrayfun( @(r) r.perrors, inst.results);
        end
        function res = perrors_true(inst)
            res = arrayfun( @(r) r.perrors_true, inst.results);
        end        
        
        function res = punknown_test(inst)
            res = arrayfun( @(r) r.punknown_test, inst.results);
        end
        
        % means        
        function res = mean_nerrors(inst)
            res = mean(inst.nerrors);
        end
        
        function res = mean_punknown(inst)
            res = mean(inst.punknown);
        end

        function res = mean_punknown_test(inst)
            res = mean(inst.punknown_test);
        end
        
        function res = mean_nclusters(inst)
            res = mean(inst.nclusters);
        end
        
        function res = mean_nconstraints(inst)
            res = mean(inst.nconstraints);
        end        
        
        function res = mean_perrors(inst)
            res = mean(inst.perrors);
        end
        function res = mean_perrors_true(inst)
            res = mean(inst.perrors_true);
        end
        
        % stddev
        function res = sd_nerrors(inst)
            res = std(inst.nerrors);
        end
        
        function res = sd_punknown(inst)
            res = std(inst.punknown);
        end
        
        function res = sd_nclusters(inst)
            res = std(inst.nclusters);
        end        
        
        function res = sd_nconstraints(inst)
            res = std(inst.nconstraints);
        end        
        
        function res = sd_punknown_test(inst)
            res = std(inst.punknown_test);
        end        
        
        function res = sd_perrors(inst)
            res = std(inst.perrors);
        end
        function res = sd_perrors_true(inst)
            res = std(inst.perrors_true);
        end        
    end
end