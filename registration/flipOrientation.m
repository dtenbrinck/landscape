function flippedData = flipOrientation(data)

% initialize struct to hold flipped data
flippedData = struct;

% flip all three channels by rotating each slice by 180°
flippedData.GFP = rot90(data.GFP,2);
flippedData.Dapi = rot90(data.Dapi,2);
flippedData.mCherry = rot90(data.mCherry,2);

% flip segmented landmark and cells by rotating each slice by 180°
flippedData.landmark = rot90(data.landmark,2);
flippedData.cells = rot90(data.cells,2);

% Flip cell coordinates % TODO!!!
flippedData.cellCoordinates = data.cellCoordinates;
%output.centCoords(1,:) = -output.centCoords(1,:);
%output.centCoords(2,:) = -output.centCoords(2,:);

end

