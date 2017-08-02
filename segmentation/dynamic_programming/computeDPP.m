%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright 2013    Daniel Tenbrinck, Xiaoyi Jiang                      %
%   Institute of Computer Science                                         %
%   University of Muenster, Germany                                       %
%   email: daniel.tenbrinck@uni-muenster.de, xjiang@uni-muenster.de       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [contour segmentation] = computeDPP(polarImage, lambda, method)

% initialize needed variables
costs = zeros(size(polarImage,1) - 1, size(polarImage,2));
pointer = costs;
contour = zeros(size(polarImage));
segmentation = contour;
delta = 0;

% compute edges of image
%gauss = fspecial('gaussian');
polarImage_gauss = polarImage; %imfilter(polarImage,gauss,'symmetric');
dx = imfilter(polarImage_gauss, [-1 1], 'symmetric');
dy = imfilter(polarImage_gauss, [-1 1]', 'symmetric');
edges = sqrt(dx.^2 + dy.^2);

% set args for cost function
args.method = method;
args.delta = delta;
args.pixelsAbove = zeros(size(polarImage));
args.sumPixelsAbove = zeros(size(polarImage));
args.pixelsBeneath = zeros(size(polarImage));
args.sumPixelsBeneath = zeros(size(polarImage));
args.pointer = zeros(size(polarImage));

waitbarHandle = waitbar(0,'Segmenting image...');

%%% initializing first column
for i=1:size(polarImage,1)-1-delta
    
    args.pixelsAbove(i,1) = numel(polarImage(1:i,1));
    args.sumPixelsAbove(i,1) = sum(polarImage(1:i,1));
    args.pixelsBeneath(i,1) = numel(polarImage(i+1:end,1));
    args.sumPixelsBeneath(i,1) = sum(polarImage(i+1:end,1));
    args.m0 = mean( polarImage(1:i,1) );
    args.m1 = mean( polarImage(i+1:end,1) );
    args.rowIndex = i;
    args.columnIndex = 1;
    args.edges = edges(:,1);
    args.lastColumn = 0;
    args.lambda = 0;
        
    costs(i,1) = computeCosts( polarImage(:,1), args ) ; 
end

% columnwise dynamic programming
for j=2:size(costs,2)
    
    waitbar(j / size(costs,2), waitbarHandle);
    
    args.columnIndex = j;
    
    % MALON >= 10
    for i=1:size(polarImage,1)-1-delta
        
        % compute column mean values above and beneath this pixel
        args.m0 = mean(polarImage(1:i,j));
        args.m1 = mean(polarImage(i+1:end,j));
        args.rowIndex = i;
        args.edges = edges(:,j);
        args.pixelsAbove(i,j) = numel(polarImage(1:i,j));
        args.sumPixelsAbove(i,j) = sum(polarImage(1:i,j));
        args.pixelsBeneath(i,j) = numel(polarImage(i+1:end,j));
        args.sumPixelsBeneath(i,j) = sum(polarImage(i+1:end,j));
        
        %%% get costs of neighboring pixels in last column
        % exception handling for the special case of top row
        if i > 1  % TESTING!!!!!
            cost1 = costs(i-1,j-1);
        else
            if strcmp(method, 'Sobel')
                cost1 = -1e14;
            else
                cost1 = 1e14;
            end
        end
        % gets costs from last column
        cost2 = costs(i,j-1);
        % exception handling for the special case of bottom row
        if i < size(costs,1)-delta
            cost3 = costs(i+1,j-1);
        else
           if strcmp(method, 'Sobel')
                cost3 = -1e14;
            else
                cost3 = 1e14;
            end
        end
        tmp = [cost1 cost2 cost3];
        args.lastColumn = tmp;
        
        %%% determine least costs from last column to set pointer
        if strcmp(method, 'Sobel')
            index = find(tmp == max(tmp(:)));
        else
            index = find(tmp == min(tmp(:)));
        end
               
        if index == 1
            pointer(i,j) = i-1;
            
            % add current costs and minimum costs from last column
            args.lambda = lambda;
            args.pointer = pointer;
            costs(i,j) = computeCosts( polarImage, args ); 
        
        elseif index == 2
            pointer(i,j) = i;
            
            % add current costs and minimum costs from last column
            args.lambda = 0;
            args.pointer = pointer;
            costs(i,j) = computeCosts( polarImage, args ); 
        
        elseif index == 3
            pointer(i,j) = i+1;
            
            % add current costs and minimum costs from last column
            args.lambda = lambda;
            args.pointer = pointer;
            costs(i,j) = computeCosts( polarImage, args ); 
        end
        
    end
end

close(waitbarHandle);

%%% sweep from last column through the cost matrix with path of least costs
if strcmp(method, 'Sobel')
    best_costs_row = find( costs(1:size(costs,1)-1-delta,size(costs,2)) == max(costs(1:size(costs,1)-1-delta,size(costs,2))) ) ;
else
    best_costs_row = find( costs(1:size(costs,1)-1-delta,size(costs,2)) == min(costs(1:size(costs,1)-1-delta,size(costs,2))) ) ;
end

contour(best_costs_row, size(costs,2)) = 1;
segmentation(1:best_costs_row, size(costs,2)) = 1;
previous_column = pointer(best_costs_row, size(costs,2));

sum_edges = 0;
for j = size(costs,2)-1 : -1 : 1
    sum_edges = edges(previous_column, j) + sum_edges;
    contour(previous_column,j) = 1;
    segmentation(1:previous_column, j) = 1;
    previous_column = pointer(previous_column,j);
end

%%% ONLY FOR TESTING PURPOSES
%figure; imagesc(costs)

end






%%%%%%% Auxiliary functions

function costs = computeCosts(data, args)
        
% extract parameters for cost function
method = args.method;
m0 = args.m0;
m1 = args.m1;
pointer = args.pointer;
i = args.rowIndex;
j = args.columnIndex;
edges = args.edges;
lambda = args.lambda;
delta = args.delta;
lastColumn = args.lastColumn;

if strcmp(method, 'Chan-Vese-L2') 
    costs = sum( (data(1:i,j) - m0).^2 ) + sum( (data(i+1:end,j) - m1).^2 ) + min(lastColumn(:)) + lambda;   
elseif strcmp(method, 'Chan-Vese-L1') 
    costs = sum( abs(data(1:i,j) - m0) ) + sum( abs(data(i+1:end,j) - m1) )  + lambda + min(lastColumn(:));
elseif strcmp(method, 'Chan-Vese-L1+Sobel') 
    costs = sum( abs(data(1:i,j) - m0) ) + sum( abs(data(i+1:end,j) - m1) ) + min(lastColumn(:)) - 15*edges(i) + lambda;
elseif strcmp(method, 'Sobel') 
    costs = edges(i) + max(lastColumn(:)) - lambda;
elseif strcmp(method, 'Malon')
    m1 = mean(data(1:i+delta));
    costs = sum( (data(1:i,j) - m0).^2 ) / i - sum( (data(1:i+delta,j) - m1).^2 ) / (i+delta) + lambda + 1  + min(lastColumn(:));
elseif strcmp(method, 'Chan-Vese-L2-inc')
    costStructure = getIncCosts(data,i,j,pointer,args);
    cost1 = sum( abs(data(1:i,j) - costStructure.m0_1).^2 ) + sum( abs(data(i+1:end,j) - costStructure.m1_1).^2 ) + lambda;
    cost2 = sum( abs(data(1:i,j) - costStructure.m0_2).^2 ) + sum( abs(data(i+1:end,j) - costStructure.m1_2).^2 ) + lambda;
    cost3 = sum( abs(data(1:i,j) - costStructure.m0_3).^2 ) + sum( abs(data(i+1:end,j) - costStructure.m1_3).^2 ) + lambda;
    costs = min([cost1 cost2 cost3]) + min(lastColumn(:));
elseif strcmp(method, 'Chan-Vese-L1-inc')
    costStructure = getIncCosts(data,i,j,pointer,args);
    cost1 = sum( abs(data(1:i,j) - costStructure.m0_1) ) + sum( abs(data(i+1:end,j) - costStructure.m1_1) ) + lambda;
    cost2 = sum( abs(data(1:i,j) - costStructure.m0_2) ) + sum( abs(data(i+1:end,j) - costStructure.m1_2) ) + lambda;
    cost3 = sum( abs(data(1:i,j) - costStructure.m0_3) ) + sum( abs(data(i+1:end,j) - costStructure.m1_3) ) + lambda;
    costs = min([cost1 cost2 cost3]) + min(lastColumn(:));
end


end


function costs = getIncCosts(data,i,j,pointer, args)

pixelsAbove1 = 0;
pixelsBeneath1 = 0;
sumPixelsAbove1 = 0;
sumPixelsBeneath1 = 0;
pixelsAbove2 = 0;
pixelsBeneath2 = 0;
sumPixelsAbove2 = 0;
sumPixelsBeneath2 = 0;
pixelsAbove3 = 0;
pixelsBeneath3 = 0;
sumPixelsAbove3 = 0;
sumPixelsBeneath3 = 0;

pixelsAbove = numel(data(1:i,j));
sumPixelsAbove = sum(data(1:i,j));
pixelsBeneath = numel(data(i+1:end,j));
sumPixelsBeneath = sum(data(i+1:end,j));

%%% check first path
if j > 1
    previous_column = i-1;
    
    if i > 1
        for column = j-1:-1:1
            
            pixelsAbove1 = pixelsAbove1 + args.pixelsAbove(previous_column,column);
            sumPixelsAbove1 = sumPixelsAbove1 + args.sumPixelsAbove(previous_column,column);
            pixelsBeneath1 = pixelsBeneath1 + args.pixelsBeneath(previous_column,column);
            sumPixelsBeneath1 = sumPixelsBeneath1 + args.sumPixelsBeneath(previous_column,column);
            previous_column = pointer(previous_column,column);
            
        end
        costs.m0_1 = (sumPixelsAbove + sumPixelsAbove1) / (pixelsAbove + pixelsAbove1);
        costs.m1_1 = (sumPixelsBeneath + sumPixelsBeneath1) / (pixelsBeneath + pixelsBeneath1);
    else
        costs.m0_1 = 1e14;
        costs.m1_1 = 1e14;
    end
    
    %%% check second path
    previous_column = i;
    for column = j-1:-1:1
        
        pixelsAbove2 = pixelsAbove2 + args.pixelsAbove(previous_column,column);
        sumPixelsAbove2 = sumPixelsAbove2 + args.sumPixelsAbove(previous_column,column);
        pixelsBeneath2 = pixelsBeneath2 + args.pixelsBeneath(previous_column,column);
        sumPixelsBeneath2 = sumPixelsBeneath2 + args.sumPixelsBeneath(previous_column,column);
        previous_column = pointer(previous_column,column);
        
    end
    
    costs.m0_2 = (sumPixelsAbove + sumPixelsAbove2) / (pixelsAbove + pixelsAbove2);
    costs.m1_2 = (sumPixelsBeneath + sumPixelsBeneath2) / (pixelsBeneath + pixelsBeneath2);
    
    %%% check third path
    if i < size(data,1)-1
        previous_column = i+1;
        for column = j-1:-1:1
            
            pixelsAbove3 = pixelsAbove3 + args.pixelsAbove(previous_column,column);
            sumPixelsAbove3 = sumPixelsAbove3 + args.sumPixelsAbove(previous_column,column);
            pixelsBeneath3 = pixelsBeneath3 + args.pixelsBeneath(previous_column,column);
            sumPixelsBeneath3 = sumPixelsBeneath3 + args.sumPixelsBeneath(previous_column,column);
            previous_column = pointer(previous_column,column);
            
        end
        costs.m0_3 = (sumPixelsAbove + sumPixelsAbove3) / (pixelsAbove + pixelsAbove3);
        costs.m1_3 = (sumPixelsBeneath + sumPixelsBeneath3) / (pixelsBeneath + pixelsBeneath3);
    else
        costs.m0_3 = 1e14;
        costs.m1_3 = 1e14;
    end
    
else
    costs.m0_1 = sumPixelsAbove / pixelsAbove;
    costs.m1_1 = sumPixelsBeneath / pixelsBeneath;
    costs.m0_2 = costs.m0_1;
    costs.m1_2 = costs.m1_1;
    costs.m0_3 = costs.m0_1;
    costs.m1_3 = costs.m1_1;
end

end
