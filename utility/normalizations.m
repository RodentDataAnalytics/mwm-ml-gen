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
        case 'scale'
            %normalise each column
            for i = 1:size(x,2)
                %normalise to [0 1]
                tmp = (x(:,i)-min(x(:,i))) / (max(x(:,i))-min(x(:,i)));
                %scale
                try
                    range = varargin{2} - varargin{1};
                    tmp = (tmp*range) + varargin{1};
                catch
                end
                x(:,i) = tmp;
            end
    end
end

