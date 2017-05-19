function test_smoothing(R)
%R = arena radius

    sigma = [R/2,R,(3/2)*R,2*R];
    t_s = {'0.5R','R','1.5R','2R'};
    threshold = [R,1.5*R,2*R,2.5*R,3*R,3.5*R];
    t_thres = {'R','1.5R','2R','2.5R','3R','3.5R'};

    f = figure;
    for i = 1:length(sigma)
        ds = 0;
        ty = exp( (- (ds(end)^2) ) / ( 2* (sigma(i)^2) ) );
        fty = ty;
        while ty > 0.0001
            ds(end+1) = ds(end) + 1;
            ty = exp( (- (ds(end)^2) ) / ( 2* (sigma(i)^2) ) );
            fty = [fty,ty];
        end   

        subplot(2,2,i);
        plot(ds,fty,'b.','markersize',10);
        hold on;
        for t = 1:length(threshold)
            y = exp( (- (threshold(t)^2) ) / ( 2* (sigma(i)^2) ) );
            if y < 0.10
                continue;
            end        
            %vertical
            plot([threshold(t),threshold(t)],[0,y],'color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',1);
            %horizontal
            plot([0,threshold(t)],[y,y],'color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',1);;
            %point
            plot(threshold(t),y,'r*','markersize',10);
            %text
            txt = strcat('\leftarrow (',strcat(t_thres(t),' , ',sprintf('%.2f',y),')'));
            text(threshold(t),y+0.01,txt,'FontSize',12);
        end
        set(gca,'FontSize',12)
        title(strcat('Sigma=',t_s(i)));
        xlabel('distance (cm)','FontSize',12);
        hold off;
    end   
end