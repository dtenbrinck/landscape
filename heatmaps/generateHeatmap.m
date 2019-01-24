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
        heatmapStruct.MIP.Top = max(accumulator(:,:,1:size(accumulator,3)/2),[],3);
        heatmapStruct.MIP.Head = reshape(max(accumulator(:,1:size(accumulator,2)/2,:),[],2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.MIP.Tail = reshape(max(accumulator(:,size(accumulator,2)/2+1:end,:),[],2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.MIP.Side1 = reshape(max(accumulator(1:size(accumulator,1)/2,:,:),[],1),[size(accumulator,2),size(accumulator,3)]);
        heatmapStruct.MIP.Side2 = reshape(max(accumulator(size(accumulator,1)/2+1:end,:,:),[],1),[size(accumulator,2),size(accumulator,3)]);
    elseif strcmp(heatmaptypes(i),'SUM')
        heatmapStruct.SUM.Top = sum(accumulator(:,:,1:size(accumulator,3)/2),3);
        heatmapStruct.SUM.Head = reshape(sum(accumulator(:,1:size(accumulator,2)/2,:),2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.SUM.Tail = reshape(sum(accumulator(:,size(accumulator,2)/2+1:end,:),2),[size(accumulator,1),size(accumulator,3)]);
        heatmapStruct.SUM.Side1 = reshape(sum(accumulator(1:size(accumulator,1)/2,:,:),1),[size(accumulator,2),size(accumulator,3)]);
        heatmapStruct.SUM.Side2 = reshape(sum(accumulator(size(accumulator,1)/2+1:end,:,:),1),[size(accumulator,2),size(accumulator,3)]);
    elseif strcmp(heatmaptypes(i),'PEAL')
        
    end 
end


end

