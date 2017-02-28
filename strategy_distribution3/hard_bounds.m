function [ w ] = hard_bounds(w)
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
end

