function CoMs = getCoMs(cellImages,resolution)


% initialize container for center-of-masses
CoMs = zeros(resolution);

% iterate over all data sets
for k=1:length(cellImages)
  
  % only take valid cells (manually marked)
  if (cellImages{k}.valid == 1)
    
    % get segmented cells
    cells = cellImages{k}.cells;
    
    % delete all NaN entries
    cells(isnan(cells)) = 0;
    
    % search for connected components
    CC=bwconncomp(cells,18);
    
    %Counter=Counter+CC.NumObjects;
    
    for l=1:CC.NumObjects
      
      % get coordinates of current cell
      [y x z] = ind2sub(resolution,CC.PixelIdxList{l});
      
      % compute center-of-mass for current cell
      coordinates = round(mean(cat(2,y,x,z),1));
      
      % compute corresponding index
      index = sub2ind(resolution,coordinates(1),coordinates(2),coordinates(3));
      
      % increase cell counter
      CoMs(index) = CoMs(index) + 1;
    
    end
    
  end
end

end