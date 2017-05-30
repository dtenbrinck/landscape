function gatheredData = saveResults( experimentData, processedData, registeredData, ellipsoid, transformationMatrix, rotationMatrix, results_filename )
%SAVERESULTS Summary of this function goes here
%   Detailed explanation goes here

% save results
% only save needed results
gatheredData = struct;
gatheredData.filename = experimentData.filename;


% important original data
gatheredData.experiment.size = size(experimentData.Dapi);
gatheredData.experiment.DapiMIP = computeMIP(experimentData.Dapi);
gatheredData.experiment.GFPMIP = computeMIP(experimentData.GFP);
gatheredData.experiment.mCherryMIP = computeMIP(experimentData.mCherry);


% important processed data
gatheredData.processed.size = size(processedData.Dapi);

gatheredData.processed.Dapi = uint8(processedData.Dapi);
gatheredData.processed.GFP = uint8(processedData.GFP);
gatheredData.processed.mCherry = uint8(processedData.mCherry);

gatheredData.processed.DapiMIP = computeMIP(processedData.Dapi);
gatheredData.processed.GFPMIP = computeMIP(processedData.GFP);
gatheredData.processed.mCherryMIP = computeMIP(processedData.mCherry);

gatheredData.processed.landmarkMIP = computeMIP(processedData.landmark);
gatheredData.processed.cellsMIP = computeMIP(processedData.cells);
gatheredData.processed.cellCoordinates = processedData.cellCoordinates;


% important registered data
gatheredData.registered.size = size(registeredData.Dapi);
gatheredData.processed.ellipsoid = ellipsoid;
gatheredData.registered.transformation_normalization = transformationMatrix;
gatheredData.registered.transformation_rotation = rotationMatrix;
gatheredData.registered.transformation_full = transformationMatrix * rotationMatrix';

% gatheredData.registered.Dapi = registeredData.Dapi;
% gatheredData.registered.GFP = registeredData.GFP;
% gatheredData.registered.mCherry = registeredData.mCherry;

gatheredData.registered.DapiMIP = computeMIP(registeredData.Dapi);
gatheredData.registered.GFPMIP = computeMIP(registeredData.GFP);
gatheredData.registered.mCherryMIP = computeMIP(registeredData.mCherry);

gatheredData.registered.landmarkMIP = computeMIP(registeredData.landmark);
gatheredData.registered.cellsMIP = computeMIP(registeredData.cells);
gatheredData.registered.cellCoordinates = registeredData.cellCoordinates;


save(results_filename,'gatheredData');
end

