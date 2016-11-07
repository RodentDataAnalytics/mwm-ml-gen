function lineformat = get_lineformat
%LINEFORMAT reads the tags configuration file and gets id,color,linestyle
    configs = parse_tags;
    lineformat = cell(size(configs,1)-1,4);
    skip = 1;
    for i = 1:size(lineformat,1)
        lineformat{i,1} = configs{i+skip,1};
        lineformat{i,2} = configs{i+skip,3};
        lineformat{i,3} = configs{i+skip,5};
        switch configs{i+skip,6}
            case 'Solid'
                lineformat{i,4} = '-';
            case '-'
                lineformat{i,4} = '-';
            case 'Dashed'   
                lineformat{i,4} = '--';
            case '--'
                lineformat{i,4} = '--';
            case 'Dotted'
                lineformat{i,4} = ':';
            case ':'
                lineformat{i,4} = ':';    
            case 'Dash-dotted'    
                lineformat{i,4} = '-.';
            case '-.'    
                lineformat{i,4} = '-.';                
        end
    end   
end    