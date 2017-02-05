function cells = getCells(cellImages,resolution)

% initialize container for center-of-masses
cells = zeros(resolution);

% iterate over all data sets
for k=1:length(cellImages)
  
  % only take valid cells (manually marked)
  if (cellImages{k}.valid == 1)
    
    % get segmented cells
    tmp = cellImages{k}.cells;
    
    % delete all NaN entries
    tmp(isnan(tmp)) = 0;
    
    % increase cell counter
    cells = cells + tmp;
    
  end
end

end