function gatheredData = saveResultsDynamics( experimentData, processedData, registeredData, ellipsoid, transformationMatrix, rotationMatrix, results_filename )
%SAVERESULTS Summary of this function goes here
%   Detailed explanation goes here

% save results
% only save needed results
gatheredData = struct;
gatheredData.filename = experimentData.filename;


% important original data
gatheredData.experiment.size = size(processedData.Dapi);

if isfield(experimentData,'Dapi')
  gatheredData.experiment.DapiMIP = computeMIP(experimentData.Dapi);
  gatheredData.experiment.GFPMIP = computeMIP(experimentData.GFP);
else
  gatheredData.experiment.DapiMIP = experimentData.DapiMIP;
  gatheredData.experiment.GFPMIP = experimentData.GFPMIP;
end
  
% important processed data
gatheredData.processed.size = size(processedData.Dapi);

gatheredData.processed.Dapi = uint8(processedData.Dapi);
gatheredData.processed.GFP = uint8(processedData.GFP);

gatheredData.processed.DapiMIP = computeMIP(processedData.Dapi);
gatheredData.processed.GFPMIP = computeMIP(processedData.GFP);

gatheredData.processed.landmark = logical(processedData.landmark);
gatheredData.processed.cells = (processedData.landmark);
gatheredData.processed.landmarkMIP = computeMIP(processedData.landmark);

if isfield(processedData, 'nuclei') % check for backward compatibilty
    gatheredData.processed.nucleiMIP = computeMIP(processedData.nuclei);
end

if isfield(processedData, 'dynamic') % check for backward compatibilty
    gatheredData.processed.dynamic.cellVelocities = processedData.dynamic.cellVelocities;
end

% important registered data
gatheredData.registered.size = size(registeredData.Dapi);
gatheredData.processed.ellipsoid = ellipsoid;
gatheredData.registered.transformation_normalization = transformationMatrix;
gatheredData.registered.transformation_rotation = rotationMatrix;
gatheredData.registered.transformation_full = transformationMatrix * rotationMatrix';

gatheredData.registered.DapiMIP = computeMIP(registeredData.Dapi);
gatheredData.registered.GFPMIP = computeMIP(registeredData.GFP);

gatheredData.registered.landmarkMIP = computeMIP(registeredData.landmark);

% this includes now coordinates of the dynamic PGC information
if isfield(registeredData, 'cellCoordinates')
    gatheredData.registered.cellCoordinates = registeredData.cellCoordinates;
end
if isfield(registeredData, 'nuclei') % check for backward compatibilty
    gatheredData.registered.nucleiMIP = computeMIP(registeredData.nuclei);
end

save(results_filename,'gatheredData');
end

