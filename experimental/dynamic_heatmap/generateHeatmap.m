function [ heatmapStruct ] = generateHeatmap( accumulator, heatmaptypes , weight)
% This function will generate a struct with heatmaps in it. The heatmaps
% will be defined by 'heatmaptypes'. heatmaptypes contains strings of the
% following:
%   'MIP':  maximum intensity projection from all sides
%   'SUM':  summation of the accumulator form all sides
%   'SUM_WEIGHTED': weighted sum of accumaltor for values like velocities
%   to be displayed in heatmap
%   'PEAL': Sargons peal-idea (In construction)
%   
% Example: heatmaptypes = {'MIP','SUM'};

%% CODE

numOfStrings = size(heatmaptypes,2);
heatmapStruct = struct;
for i=1:numOfStrings
    if strcmp(heatmaptypes(i),'MIP')
        heatmapStruct.MIP.Top = max(accumulator,[],3);
        heatmapStruct.MIP.Head = reshape(max(accumulator,[],2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.MIP.Side = reshape(max(accumulator,[],1),[size(accumulator,2),size(accumulator,3)]);
    elseif strcmp(heatmaptypes(i),'SUM') || strcmp(heatmaptypes(i),'SUM_WEIGHTED')
        heatmapStruct.SUM.Top = sum(accumulator,3);
        heatmapStruct.SUM.Head = reshape(sum(accumulator,2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.SUM.Side = reshape(sum(accumulator,1),[size(accumulator,2),size(accumulator,3)]);
        if strcmp(heatmaptypes(i),'SUM_WEIGHTED') && exist('weight','var')
            heatmapStruct.SUM_WEIGHTED.Top = weight * heatmapStruct.SUM.Top;
            heatmapStruct.SUM_WEIGHTED.Head = weight * heatmapStruct.SUM.Head;
            heatmapStruct.SUM_WEIGHTED.Side = weight * heatmapStruct.SUM.Side;
        end
    elseif strcmp(heatmaptypes(i),'PEAL')
        
    end 
end


end

