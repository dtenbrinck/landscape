function [startPoint, endPoint, a0, a1] = computeLinearRegression(segmentedData, visualize)
% COMPUTEREGRESSION: This function computes the linear regression of a
% segmented data. This is used in the context of embryo registration.
% Input: %
%   segmentedData:  This should be a map with the segmented data. The
%                   segmented data should be indicated by a 1. 
%   visualize:      When there should be a visualization of the linear
%                   regression type in 'true'. Default is 'false'.
% Output: %
%   startPoint:     This is the first x-value, s.t. f(x) is on the data
%                   set.
%   endPoint:       This is the last x-value, s.t. f(x) is on the data
%                   set.
%   a1:             This is the slope of the linear regression function.
%   a0:             This is the intercept of the linear regression
%                   function.
%
%% Main Code %%

if nargin == 1
    visualize = 'false';
end
% Find the coordinates of the data
[Y,X] = find(segmentedData);    
n = numel(X);
% Compute the arithmetic mean
xbar = sum(X)/n;
ybar = sum(Y)/n;

% Compute linear regression
a1 = (sum(X.*Y)-n*xbar*ybar)/(sum(X.^2)-n*xbar^2);  % slope
a0 = ybar-a1*xbar;                                  % intercept


% Compute the line
p = 1:size(segmentedData,2);
line = a1*p+a0;
% Delete every point on the line that reaches out of the domain
p(line<0) = [];
line(line<0) = [];
p(line>size(segmentedData,1)) = [];
line(line>size(segmentedData,1)) = [];


% Get the linear indices of line on the segmented data
indexi = sub2ind(size(segmentedData),round(line),p);

% Delete each that would reach out of the plot
indexi(indexi>numel(segmentedData)) = [];

% Find start and end point of the line on the data set
[row,~] = find(segmentedData(indexi(:)));

% endPoint = row(end);
% startPoint = row(1);
[~,startPoint] = ind2sub(size(segmentedData),indexi(row(1)));
[~,endPoint] = ind2sub(size(segmentedData),indexi(row(end)));

if strcmp(visualize,'true')
    p = startPoint:endPoint;
    line = a1*p+a0;
    figure, scatter(X,Y);
    hold on;
    plot(p,line);
    hold off;
end


end

