function MM=robustcsvread(filename, varargin)
% ROBUSTCSVREAD reads in CSV files with
% different number of columns on different
% lines
%
% This can easily be extended to give back
% a numeric matrix or mixed numeric and 
% string cell array.
%
% IT'S NOT FANCY, BUT IT WORKS

% robbins@bloomberg.net
% michael.robbins@us.cibc.com

% Tiago Gehring, Mar/2015: added delimiter options, started messing the
% code. Figured why not?
MM = {};
[line_delim, delim] = process_options(varargin, ...
            'LineDelimiter', '\n', 'Delimiter', ',' ...
          );            

fid=fopen(filename,'r');
slurp=fscanf(fid,'%c');
slurp=regexprep(slurp,'\t',',');
fclose(fid);

M = strread(slurp,'%s','delimiter', line_delim);
for i=1:length(M)
    temp=strread(M{i},'%s','delimiter', delim);
    for j=1:length(temp)
        MM{i,j}=temp{j};
    end
end