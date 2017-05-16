function [ fixed_data, cols ] = fix_UTF16LE_data(data)
%FIX_UTF16LE_DATA Summary of this function goes here
%   Detailed explanation goes here

    % First get rid of " and count max number or ;
    cols = 0;
    for i = 1:size(data,1)
        tmp = data{i};
        tmp(regexp(tmp,'["]')) = [];
        data{i} = tmp;
        count = length(strfind(data{i},';'));
        if count > cols
            cols = count;
        end
    end
    
    % For each ';' split to columns
    fixed_data = cell(size(data,1),cols);
    for i = 1:size(data,1)
        count = strfind(data{i},';');
        for j = 2:length(count) %we have always ; in the end
            fixed_data{i,j} = data{i}(count(j-1)+1:count(j)-1);
        end
        fixed_data{i,1} = data{i}(1:count(1)-1);
    end
end

