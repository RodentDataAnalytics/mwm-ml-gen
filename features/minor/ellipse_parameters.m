function [ a, b, theta] = ellipse_parameters( A )
%ELLIPSE_PARAMETERS Returns major/minor axis and inclination of a ellipse
    [~, d, v] = svd(A);
    a = 1./sqrt(d(1, 1));
    b = 1./sqrt(d(2, 2));
    theta = acos(v(1, 1));
end

