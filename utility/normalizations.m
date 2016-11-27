function [x] = normalizations(x,option,varargin)
%NORMALIZATIONS, various normalizations for vectors
%INPUT:
% x: a vector
% option: 'mean' , 'one' , 'n-norm'
% varargin: For 'n-norm' option it specifies the power n.
%           If omitted then n = 2 (Euclidean).
%OUTPUT:
% x: the normalized input vector

    switch option
        case 'mean'
            % common in PCA
            x = x - mean(x);
        case 'one'
            % sum to 1
            x = x/sum(x);
        case 'n-norm'
            % sum(abs(x).^n)^(1/n) for 1<=n<inf
            % if n = 2    => Euclidean
            % if n = inf  => max(abs(x))
            % if n = -inf => min(abs(x))
            try
                x = x/norm(x,varargin{1});
            catch
                x = x/norm(x,2);
            end    
    end

end

