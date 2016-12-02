data = [1 1 1 1 0 1 1 1 1 1 0 1 1 0 1 1 1 1 0 1];
%data = y = [8.1 8.0 8.1];


% THE CONFIDENCE INTERVAL
% 
% This is a recipe for computing the confidence interval. The strategy is:
% compute the average
% Compute the standard deviation of your data
% Define the confidence interval, e.g. 95% = 0.95
% compute the student-t multiplier. This is a function of the confidence interval you specify, and the number of data points you have minus 1. You subtract 1 because one degree of freedom is lost from calculating the average.
% The confidence interval is defined as ybar +- T_multiplier*std/sqrt(n).
% 
% the tinv command provides the T_multiplier

ci = 0.95;
ybar = mean(data);
s =std(data);
alpha = 1 - ci;
n = length(data); %number of elements in the data vector
T_multiplier = tinv(1-alpha/2, n-1);
% the multiplier is large here because there is so little data. That means
% we do not have a lot of confidence on the true average or standard
% deviation
ci95 = T_multiplier*s/sqrt(n);

% confidence interval
sprintf('The confidence interval is %1.1f +- %1.1f',ybar,ci95);
[ybar - ci95, ybar + ci95];

% we can say with 95% confidence that the true mean lies between these two
% values.