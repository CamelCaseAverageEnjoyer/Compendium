function [x_max, x_mean, x_sigma] = getMaxMeanSigma(x)
%GETMEANVALUE Summary of this function goes here
%   Detailed explanation goes here

x_max = max(abs(x));
x_mean = sum(x)/length(x);
x_sigma = sqrt(sum((x - x_mean).^2)/(length(x) - 1));

end

