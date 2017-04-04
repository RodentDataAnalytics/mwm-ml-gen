function [ w, avg_w ] = hard_bounds(w,varargin)
%function [ w, avg_w ] = hard_bounds(w,varargin)
%HARD_BOUNDS uses min, max weight bounds

    avg_w = max(w) - min(w);
    avg_w = avg_w / 2;
    avg_w = avg_w + min(w);
    for i = 1:length(w)
        if w(i) < avg_w
            w(i) = min(w);
        else
            w(i) = max(w);
        end
    end
    
    if ~isempty(varargin) %use true lengths to do the bounding
        Lmax_k = varargin{1};
        avg_w = sum(Lmax_k) / length(Lmax_k);
        for i = 1:length(w)
            if Lmax_k < avg_w
                w(i) = min(Lmax_k);
            else
                w(i) = max(Lmax_k);
            end
        end
    end
end

