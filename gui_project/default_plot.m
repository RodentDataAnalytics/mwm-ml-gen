function default_plot(shape)
%DEFAULT_PLOT plots a shape

    %plot a circle
    switch shape
        case 'circle'
            pos = [1 1 2 2];
            rectangle('Position',pos,'Curvature',[1 1]);
            axis square;
        case 'rectangle'
            pos = [1 1 2 2];
            rectangle('Position',pos);
            axis square;
        otherwise
            return
    end    
    
end

