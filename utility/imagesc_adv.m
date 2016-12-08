function z = imagesc_adv(mymatrix, varargin)
%IMAGESC_ADV display matrix as image with scaled colors
%Defaults:
% colormap = inverse gray
% xTickLabel_ = A, ..., Z, AA, ..., AZ, ..., ZZ. (max = 702)
% YTickLabel_ = 1, ... 2147483647. (max = intmax)
%Custom:
% colomap, colormap_range, colorbar, XTickLabel, YTickLabel

% Thanks to: gnovice @stackoverflow.com
%http://stackoverflow.com/questions/3942892/how-do-i-visualize-a-matrix-with-colors-and-values-displayed 
    
    z = figure;
    set(z,'Visible','off');
        
    imagesc(mymatrix); 

    %% Default Values
    colormap(flipud(gray));
    YTickLabel_ = {};
    XTickLabel_ = generate_alphabet_vector(size(mymatrix,2));
    if isempty(XTickLabel_)
        fprintf('Cannot generate image. x-axis size can be up to 676.');
        z = {};
        return;
    end
    for i = 1:size(mymatrix,1)
        YTickLabel_ = [YTickLabel_ , num2str(i)];
    end

    %% User Defined Values
    for i = 1:length(varargin)
        if isequal(varargin{i},'colormap')
            colormap(varargin{i+1});
        elseif isequal(varargin{i},'colormap_range')
            caxis(varargin{i+1});
        elseif isequal(varargin{i},'colorbar')
            if isequal(varargin{i+1},'on') || isequal(varargin{i+1},'ON') || isequal(varargin{i+1},1)
                colorbar;
            end
        elseif isequal(varargin{i},'XTickLabel')
            XTickLabel_ = varargin{i+1};
        elseif isequal(varargin{i},'YTickLabel')
            YTickLabel_ = varargin{i+1};
        end
    end

    %% EXECUTE
    %Create strings from the matrix values
    textStrings = num2str(mymatrix(:),'%0.1f');  
    %Remove any space padding
    textStrings = strtrim(cellstr(textStrings));  
    %Create x and y coordinates for the strings
    [x,y] = meshgrid(1:size(mymatrix,1));   
    %Plot the strings
    hStrings = text(x(:),y(:),textStrings(:),'HorizontalAlignment','center');
    %Get the middle value of the color range
    midValue = mean(get(gca,'CLim'));
    %Choose white or black for the
    %text color of the strings so
    %they can be easily seen over
    %the background color
    textColors = repmat(mymatrix(:) > midValue,1,3); 
    %Change the text colors
    set(hStrings,{'Color'},num2cell(textColors,2));  
    %Change the axes tick marks and tick labels
    set(gca,'XTick',1:size(mymatrix,1),'XTickLabel',XTickLabel_,... 
            'YTick',1:size(mymatrix,2),'YTickLabel',YTickLabel_,...
            'TickLength',[0 0]);     
end

