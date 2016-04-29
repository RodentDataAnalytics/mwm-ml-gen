function out = iff(expr, true_val, false_val)
    if expr
        out = true_val;
    else
        out = false_val;
    end
end