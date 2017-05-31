function [ full_accumulator ] = computeAccumulator( allCellCoords, gridSize )
%This function computes the accumulator for the heatmap

allCellCoords(1:2,:) = allCellCoords(2:-1:1,:);

% check if cell coordinates are given in reference space or in data space
if max(allCellCoords(:)) < 3
    
    maxC = max(abs(allCellCoords(:)));
    
    transformed_cellCoords = round((allCellCoords+maxC) * (gridSize-1)/(2*maxC) + 1);

    full_accumulator = accumarray(transformed_cellCoords', 1);
    
    full_accumulator = padarray(full_accumulator,...
        [gridSize - size(full_accumulator,1),...
         gridSize - size(full_accumulator,2),...
         gridSize - size(full_accumulator,3)],...
         0,...
         'post');
    
else
    
%      transformed_cellCoords = allCellCoords;
%      transformed_cellCoords(3,:) = transformed_cellCoords(3,:) * 20;
% %     transformed_cellCoords(1:2,:) = transformed_cellCoords(2:-1:1,:);
%      minX = min(transformed_cellCoords(1,:));
%      minY = min(transformed_cellCoords(2,:));
%      minZ = min(transformed_cellCoords(3,:));
%      
%      shifted_cellCoords = transformed_cellCoords;
%      shifted_cellCoords(1,:) = shifted_cellCoords(1,:) - minX;
%      shifted_cellCoords(2,:) = shifted_cellCoords(2,:) - minY;
%      shifted_cellCoords(3,:) = shifted_cellCoords(3,:) - minZ;
%      
%      maxCoord = max(shifted_cellCoords(:));
%      
%      scaled_cellCoords = round(shifted_cellCoords ./ maxCoord * (gridSize-1) + 1);
    
     full_accumulator = accumarray(allCellCoords', 1);
     
%      full_accumulator = padarray(full_accumulator,...
%         [gridSize - size(full_accumulator,1),...
%          gridSize - size(full_accumulator,2),...
%          gridSize - size(full_accumulator,3)],...
%          0,...
%          'post');
end

end

