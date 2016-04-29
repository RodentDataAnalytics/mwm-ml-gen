function draw_ellipse(xc, yc, a, b, inc, style)
%DRAW_ELLIPSE Summary of this function goes here
%   Detailed explanation goes here
    t = linspace(0,2*pi);
    px = a*cos(t);
    py = b*sin(t);
    inc = inc;
    x = xc + px*cos(inc) - py*sin(inc);
    y = yc + px*sin(inc) + py*cos(inc);
    plot(x, y, '-r');
end