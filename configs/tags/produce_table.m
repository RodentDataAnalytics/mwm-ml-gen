function data = produce_table(contents,cols)
%PRODUCE_TABLE manipulate the data for the table

    %skip system tags
    [contents, ~] = skip_system_tags(contents);
  
    str = cell(size(contents,1),1);
    data = cell(size(contents,1),size(contents,2));
    for i = 1:size(contents,1)
        %format color as: #FFFFFF and text same as color
        color_tmp = strcat('[',contents{i,4},',',contents{i,5},',',contents{i,6},']');
        color = [str2num(contents{i,4}) , str2num(contents{i,5}) , str2num(contents{i,6})];
        color = dec2hex(round(color.*255));
        color = ['#',color(1,:),color(2,:),color(3,:)];
        %str{i} = strcat(['<html><body bgcolor="' color '" text="' num2str(color_tmp) '" width="80px">'], color);
        str{i} = strcat(['<html><body bgcolor="' color '" font color="' color '" text="' color_tmp '" width="80px">'], color);
        %form the final data
        data{i,1} = contents{i,1};
        data{i,2} = contents{i,2};
        data{i,3} = contents{i,3};
        data{i,4} = str{i};
        data{i,5} = contents{i,7};
        data{i,6} = contents{i,9};
        data{i,7} = contents{i,8};
    end    
    
    data = data(:,1:cols);
end

