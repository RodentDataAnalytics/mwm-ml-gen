function keep = clustering_performance(varargin)

    % Initialize
    if isdeployed
        datapath = fullfile(ctfroot,'import','original_data_1_extra');
    else
        datapath =  fullfile(pwd,'import','original_data_1_extra');        
    end   
    if ismac
        desk_path = char(java.lang.System.getProperty('user.home'));
        desk_path = fullfile(desk_path,'Desktop');
    else
        desk_path = char(getSpecialFolder('Desktop'));
    end
    output_dir = desk_path;
    [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
    
    % Execute
    c = dir(fullfile(datapath,'*.mat'));
    keep = cell(length(c),1);
    for iter = 1:length(c)
        load(fullfile(datapath,c(iter).name))
        
        av_error = -1*ones(12,1);
        av_undefined = av_error;
        av_coverage = av_error;
        XTickLabel = cell(1,12);
        k = 1;
        for i = 1:12
            av_error(i) = mean(crossvalidation(k:k+9,2));
            av_undefined(i) = mean(crossvalidation(k:k+9,3));
            av_coverage(i) = mean(crossvalidation(k:k+9,4));
            k = k + 10;
            %XTickLabel{i} = strcat('N_{cl}:',num2str(k-1),'-',num2str(k+8));
            XTickLabel{i} = strcat(num2str(k-1),'-',num2str(k+8));
        end
        keep{iter} = [av_error , av_undefined , av_coverage]; 
        
        f = figure('units','normalized','outerposition',[0 0 1 1]);
        subplot(3,1,1);
        hold on
        plot(av_error,'k-');
        plot(av_error,'k*');
        xlabel('Number of Clusters');
        ylabel('Average Error (%)');
        hold off
        grid;
        set(gca,'LineWidth', LineWidth,'FontSize', FontSize, 'FontName', FontName,'XTick',1:length(XTickLabel),'XTickLabel',XTickLabel);
        subplot(3,1,2);
        hold on
        plot(av_undefined,'k-');
        plot(av_undefined,'k*');
        xlabel('Number of Clusters');
        ylabel('Average Undefined (%)');
        hold off
        grid;
        set(gca,'LineWidth', LineWidth,'FontSize', FontSize, 'FontName', FontName,'XTick',1:length(XTickLabel),'XTickLabel',XTickLabel);
        subplot(3,1,3);
        hold on
        plot(av_coverage,'k-');
        plot(av_coverage,'k*');
        xlabel('Number of Clusters');
        ylabel('Average Coverage (%)');
        hold off
        grid;
        set(gca,'LineWidth', LineWidth,'FontSize', FontSize, 'FontName', FontName,'XTick',1:length(XTickLabel),'XTickLabel',XTickLabel);

        export_figure(f, output_dir, c(iter).name, Export, ExportStyle);
        close(f);
    end
    
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,1,1);
    hold on
    plot(keep{1}(:,1),'k-');
    plot(keep{1}(:,1),'k*');
    plot(keep{2}(:,1),'r-');
    plot(keep{2}(:,1),'r*');
    xlabel('Number of Clusters');
    ylabel('Average Error (%)');
    hold off
    grid;
    set(gca,'LineWidth', LineWidth,'FontSize', FontSize, 'FontName', FontName,'XTick',1:length(XTickLabel),'XTickLabel',XTickLabel);
    subplot(3,1,2);
    hold on
    plot(keep{1}(:,2),'k-');
    plot(keep{1}(:,2),'k*');
    plot(keep{2}(:,2),'r-');
    plot(keep{2}(:,2),'r*');
    xlabel('Number of Clusters');
    ylabel('Average Undefined (%)');
    hold off
    grid;
    set(gca,'LineWidth', LineWidth,'FontSize', FontSize, 'FontName', FontName,'XTick',1:length(XTickLabel),'XTickLabel',XTickLabel);
    subplot(3,1,3);
    hold on
    plot(keep{1}(:,3),'k-');
    plot(keep{1}(:,3),'k*');
    plot(keep{2}(:,3),'r-');
    plot(keep{2}(:,3),'r*');
    xlabel('Number of Clusters');
    ylabel('Average Coverage (%)');
    hold off
    grid;
    set(gca,'LineWidth', LineWidth,'FontSize', FontSize, 'FontName', FontName,'XTick',1:length(XTickLabel),'XTickLabel',XTickLabel);

    export_figure(f, output_dir, 'Clustering Performance', Export, ExportStyle);
    close(f);
end

    