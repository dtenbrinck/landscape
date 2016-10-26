function [ heatmap ] = smoothHeatmap(rawheatmap,sizeInPercentage,type)

sigma = 0.5;

sizeHeatmap = size(rawheatmap);
if strcmp(type,'disk')
    filter = fspecial('disk',round(sizeInPercentage*sizeHeatmap(1)/2));
    filter(filter>0) = 1;
    heatmap = conv2(rawheatmap,filter,'same');
elseif strcmp(type,'gaussian')
    heatmap = imgaussfilt(rawheatmap,sigma,'FilterSize',round(sizeInPercentage*sizeHeatmap(1)));
end

end

