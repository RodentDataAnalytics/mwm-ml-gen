function [ColumnName,RowName,ColumnWidth] = browse_tables_graphics(option,varargin)
%BROWSE_TABLES_GRAPHICS

    font_name = '<font family=Arial>';
    font_size = '<font size=4>';
    
    switch option
        case 1 %Trajectory
            %Column + Rows names
            str = ['<html>' font_name font_size 'Trajectory</html>'];
            %str_ = ['<html>' font_name font_size '</html>'];
            str1 = ['<html>' font_name font_size '#</html>'];
            str2 = ['<html>' font_name font_size 'Group</html>'];
            str3 = ['<html>' font_name font_size 'ID</html>'];
            str4 = ['<html>' font_name font_size 'Session</html>'];
            str5 = ['<html>' font_name font_size 'Day</html>']; 
            str6 = ['<html>' font_name font_size 'Trial</html>'];
            str7 = ['<html>' font_name font_size 'Track</html>'];
            str8 = ['<html>' font_name font_size 'Latency</html>'];
            str9 = ['<html>' font_name font_size 'Speed</html>'];
            str10 = ['<html>' font_name font_size 'Length</html>'];
            ColumnWidth = {60};
            ColumnName = {str};
            RowName = {str1;str2;str3;str4,;str5;str6;str7;str8;str9;str10};
            %set(hObject,'ColumnName',ColumnName,'RowName',RowName,'ColumnWidth',ColumnWidth); 
        case 2 %Segment        
            features_names = varargin{:};
            %Column + Rows names
            str = ['<html>' font_name font_size 'Segment</html>'];
            %str_ = ['<html>' font_name font_size '</html>'];
            str1 = ['<html>' font_name font_size '#</html>'];
            str2 = ['<html>' font_name font_size 'Offset</html>'];
            RowName = cell(1,length(features_names));
            for i = 1:length(features_names)
                f_name = features_names{i};
                RowName{i} = ['<html>' font_name font_size f_name 'ID</html>'];
            end    
            ColumnName = {str};
            ColumnWidth = {60};
            RowName = [str1;str2;RowName'];
            %set(hObject,'ColumnName',ColumnName,'RowName',RowName,'ColumnWidth',ColumnWidth); 
    end
end

