function [FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs
%PARSE_CONFIGS reads the configs.txt files and returns 
%FontName, FontSize, LineWidth, Export Format and
%color/grayscale/black&white
    
    contents = read_configs;

    for i = 1:size(contents,1)
        if isequal(contents{i,1},'FontName')
            FontName = contents{i,2};
        elseif isequal(contents{i,1},'FontSize')
            FontSize = str2num(contents{i,2});
        elseif isequal(contents{i,1},'LineWidth')
            LineWidth = str2num(contents{i,2});
        elseif isequal(contents{i,1},'Export')
            Export = contents{i,2};
            split = strfind(Export,'.');
            Export = Export(split:end);
        elseif isequal(contents{i,1},'ExportStyle')
            ExportStyle = contents{i,2};
        end
    end 
    
end

