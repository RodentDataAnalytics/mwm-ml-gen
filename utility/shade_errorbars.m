function shade_errorbars(x,y,error,varargin)
%SHADE_ERRORBARS creates a shaded errorbars plot.

% Code inspired from Rob Campbell:
% https://www.mathworks.com/matlabcentral/fileexchange/26311-raacampbell-shadederrorbar
% https://github.com/raacampbell/shadedErrorBar

    Color = [0,0,0];
    LineWidth = 1;
    Transparency = 0.85;
    EColor = Color;

    for i = 1:length(varargin)
        if isequal(varargin{i},'COLOR')
            Color = varargin{i+1};
        elseif isequal(varargin{i},'LineWidth')
            LineWidth = varargin{i+1};       
        elseif isequal(varargin{i},'EColor')
            EColor = varargin{i+1};                   
        elseif isequal(varargin{i},'Transparency')
            Transparency = varargin{i+1};    
        end
    end
    
    pl = plot(x,y, 'Color',Color, 'LineWidth',LineWidth);
    
    ydata = get(pl,'YData');
    xdata = get(pl,'XData');
    error_upper = ydata + error;
    error_lower = ydata - error;
    yError=[error_lower,fliplr(error_upper)];
    xError=[xdata,fliplr(xdata)];
    tmp = find(yError < 0);
    yError(tmp) = 0;
    
    FaceColor = EColor + (1 - EColor) * Transparency;
    
    patch(xError,yError,1,'FaceColor',FaceColor,'EdgeColor','none');   
    hold on;
    plot(x,y, 'Color',Color, 'LineWidth',LineWidth);
end

