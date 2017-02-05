function [ heatmapStruct ] = generateHeatmap( accumulator, heatmaptypes )
% This function will generate a struct with heatmaps in it. The heatmaps
% will be defined by 'heatmaptypes'. heatmaptypes contains strings of the
% following:
%   'MIP':  maximum intensity projection from all sides
%   'SUM':  summation of the accumulator form all sides
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
    elseif strcmp(heatmaptypes(i),'SUM')
        heatmapStruct.SUM.Top = sum(accumulator,3);
        heatmapStruct.SUM.Head = reshape(sum(accumulator,2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.SUM.Side = reshape(sum(accumulator,1),[size(accumulator,2),size(accumulator,3)]);
    elseif strcmp(heatmaptypes(i),'PEAL')
        
    end 
end


end

