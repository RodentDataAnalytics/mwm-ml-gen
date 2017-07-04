function [ varargout ] = algorithm_statistics(option,suboption,varargin)
%ALGORITHM_STATISTICS computes various statistics about the algorithm
%performance

% OPTION 1: Optimal number of clusters.
%Consider only the two stage clustering to find optimal value(s).

    switch option
        case 1  
        %% %errors, %undefined, %coverage
            nc       = varargin{1};
            res1bare = varargin{2};
            res2bare = varargin{3};
            res1     = varargin{4};
            res2     = varargin{5};
            res3     = varargin{6};
            covering = varargin{7};
            ci_fac = 1.96/sqrt(length(nc));
            per_errors1 = arrayfun( @(x) 100*x.mean_perrors, res1bare);
            per_errors1_true = arrayfun( @(x) 100*x.mean_perrors_true, res1bare);
            per_errors_ebars1 = arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare);
            per_undefined1 = arrayfun( @(x) 100*x.mean_punknown, res1);
            per_clus_ebars1 = arrayfun( @(x) x.sd_nclusters*ci_fac, res1);
            coverage = covering*100;
            
            % return all the values
            if suboption
                varargout{1} = nc;
                varargout{2} = per_errors1;
                varargout{3} = per_undefined1;
                varargout{4} = coverage;
                varargout{5} = per_errors1_true;
                return
            end    
            
            % find mean
            mean_per_errors1 = mean(per_errors1);
            mean_per_undefined1 = mean(per_undefined1);
            mean_coverage = mean(coverage);
            mean_per_errors_ebars1 = mean(per_errors_ebars1);
            mean_per_clus_ebars1 = mean(per_clus_ebars1);
            
            % find common elements
            a = find(per_errors1 < mean_per_errors1 & per_errors1 < 10);
            b = find(per_undefined1 < mean_per_undefined1 & per_undefined1 < 40);
            c = find(coverage > mean_coverage & coverage > 70);
            d = find(per_errors_ebars1 < mean_per_errors_ebars1);
            e = find(per_clus_ebars1 < mean_per_clus_ebars1);
            common1 = intersect(intersect(a,b),c);
            common2 = intersect(d,e);
            common_all = intersect(common1,common2);
            %take error bars into consideration
            if ~isempty(common_all) 
                nc = nc(common_all);
                per_errors1 = per_errors1(common_all);
                per_undefined1 = per_undefined1(common_all);
                coverage = coverage(common_all);
            %do not take error bars into consideration    
            elseif ~isempty(common1)
                nc = nc(common1);
                per_errors1 = per_errors1(common1);
                per_undefined1 = per_undefined1(common1);
                coverage = coverage(common1);
            %no proposition send all the results back     
            else   
                disp('Could not find optimal number of clusters. The labelling quantity and quality needs to be checked');
            end
            % return
            varargout{1} = nc;
            varargout{2} = per_errors1;
            varargout{3} = per_undefined1;
            varargout{4} = coverage; 
    end         
end

