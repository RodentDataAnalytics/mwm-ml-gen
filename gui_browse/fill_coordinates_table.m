function coords = fill_coordinates_table(obj, idx)
%FILL_COORDINATES_TABLE Summary of this function goes here
%   Detailed explanation goes here

    points = obj.items(idx).points;
    coords = [points(:,1) , points(:,2) , points(:,3)];

end

