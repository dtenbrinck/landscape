function [ full_accumulator, cut_accumulator ] = computeAccumulator( allCellCoords, gridSize )
%This function computes the accumulator for the heatmap

% check if cell coordinates are given in reference space or in data space
if max(allCellCoords(:)) < 3
    transformed_cellCoords = round((allCellCoords + 1) * (gridSize-1)/2);
    
    cut_cellCoords = transformed_cellCoords;
    cut_cellCoords(:,min(transformed_cellCoords,[],1) < 0 | max(transformed_cellCoords,[],1) > gridSize-1) = [];
    cut_cellCoords = cut_cellCoords + 1;
    cut_accumulator = accumarray(cut_cellCoords', 1);
    
    minX = min(transformed_cellCoords(1,:));
    minY = min(transformed_cellCoords(2,:));
    minZ = min(transformed_cellCoords(3,:));
    
    shifted_cellCoords = transformed_cellCoords;
    shifted_cellCoords(1,:) = shifted_cellCoords(1,:) - minX + 1;
    shifted_cellCoords(2,:) = shifted_cellCoords(2,:) - minY + 1;
    shifted_cellCoords(3,:) = shifted_cellCoords(3,:) - minZ + 1;
    
    full_accumulator = accumarray(shifted_cellCoords', 1);
    
else
 
     transformed_cellCoords = allCellCoords;
     minX = min(transformed_cellCoords(1,:));
     minY = min(transformed_cellCoords(2,:));
     minZ = min(transformed_cellCoords(3,:));
     
     shifted_cellCoords = transformed_cellCoords;
     shifted_cellCoords(1,:) = shifted_cellCoords(1,:) - minX + 1;
     shifted_cellCoords(2,:) = shifted_cellCoords(2,:) - minY + 1;
     shifted_cellCoords(3,:) = shifted_cellCoords(3,:) - minZ + 1;
     
     maxCoord = max(shifted_cellCoords(:));
     scaled_cellCoords = round((shifted_cellCoords / maxCoord * (gridSize-1))) + 1;
     
     full_accumulator = accumarray(scaled_cellCoords', 1);
     cut_accumulator = full_accumulator;
end

end

