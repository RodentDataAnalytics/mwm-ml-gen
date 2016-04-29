function [ labels_data ] = labels_converter( labels_data )
%LABELS_CONVERTER Summary of this function goes here
%   Detailed explanation goes here

for i=1:length(labels_data)
    k={};
    for j=1:length(labels_data{i,2})
        if strcmp(labels_data{i,2}{1,j},'UD')
            labels_data{i,2}{1,j}=1;
        elseif strcmp(labels_data{i,2}{1,j},'TT')
            labels_data{i,2}{1,j}=2;
        elseif strcmp(labels_data{i,2}{1,j},'IC')
            labels_data{i,2}{1,j}=3;
        elseif strcmp(labels_data{i,2}{1,j},'SC')
            labels_data{i,2}{1,j}=4;
        elseif strcmp(labels_data{i,2}{1,j},'FS') 
            labels_data{i,2}{1,j}=5;
        elseif strcmp(labels_data{i,2}{1,j},'CR')
            labels_data{i,2}{1,j}=6;    
        elseif strcmp(labels_data{i,2}{1,j},'SO')
            labels_data{i,2}{1,j}=7;
        elseif strcmp(labels_data{i,2}{1,j},'SS')
            labels_data{i,2}{1,j}=8;    
        elseif strcmp(labels_data{i,2}{1,j},'ST')
            labels_data{i,2}{1,j}=9;
        end
        k{j}=labels_data{i,2}{1,j};
    end
    labels_data{i,2} = cell2mat(k);
end