% INITIALIZATION
clear; clc; close all;

% load necessary variables
root_dir = fileparts(fileparts(pwd));
addpath([root_dir '/parameter_setup/']);
p = initializeScript('processing', root_dir);
p.resolution = [1.1512, 1.1512, 5];   % 30 percent scale

% Add Data to processedData ectoderm and mesoderm
origname = uigetfile(p.dataPath,'Please select the original data!'); % Select all files to see the data
segname = uigetfile(p.dataPath,'Please select the segmented data!');


if p.debug_level >= 1; disp('Loading data...'); end

Original = load([p.dataPath '\' origname]);
processedData.DapiOriginal = Original.OriginalData.dapi;
Segm = load([p.dataPath '\' segname]);
processedData.DapiSegm = Segm.binaryX.dapi;
processedData.GFP = Original.OriginalData.gfp;
processedData.landmark = double(Segm.binaryX.gfp);
processedData.mesodermOriginal = Original.OriginalData.meso;
processedData.mesodermSegm = Segm.binaryX.meso;
processedData.ectoendoOriginal = Original.OriginalData.endo;
processedData.ectoendoSegm = Segm.binaryX.endo;

% estimate embryo surface by fitting an ellipsoid
ellipsoid = estimateEmbryoSurface(processedData.DapiOriginal, p.resolution, p.ellipsoidFitting);

% compute transformation which normalizes the estimated ellipsoid to a unit sphere
transformationMatrix = computeTransformationMatrix(ellipsoid);

[sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
            projectLandmarkOnSphere(processedData.landmark, p.resolution, ellipsoid, p.samples_sphere);
        
% estimate optimal rotation to register data to reference point with reference orientation
rotationMatrix = ...
            registerLandmark(landmarkCoordinates, p.reg);
        
transformation_registration = transformationMatrix * rotationMatrix';

% register processed data using cubic interpolation
if p.debug_level >= 1; disp('Register data...'); end

[registeredData.GFP, ~] = transformVoxelData(single(processedData.GFP), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');
[registeredData.DapiOriginal, ~] = transformVoxelData(single(processedData.DapiOriginal), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');
[registeredData.DapiSegm, ~] = transformVoxelData(single(processedData.DapiSegm), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');
[registeredData.mesodermOriginal, ~] = transformVoxelData(single(processedData.mesodermOriginal), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');
[registeredData.mesodermSegm, ~] = transformVoxelData(single(processedData.mesodermSegm), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');
[registeredData.ectoendoOriginal, ~] = transformVoxelData(single(processedData.ectoendoOriginal), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');
[registeredData.ectoendoSegm, ~] = transformVoxelData(single(processedData.ectoendoSegm), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'cubic');

% register segmentations using nearest neighbor interpolation
[registeredData.landmark, ~] = transformVoxelData(single(processedData.landmark), p.resolution, transformation_registration, ellipsoid.center, p.samples_cube, 'nearest');


dapiorigname = [origname(1:6) 'Dapi_original_data'];
gfporigname = [origname(1:6) 'GFP_original_data'];
mesodermorigname = [origname(1:6) 'Meso_original_data'];
ectoendoorigname = [origname(1:6) 'EctoEndo_original_data'];

figure; subplot(2,2,1); imagesc(computeMIP(processedData.DapiOriginal));
        title(['Original data ' dapiorigname(1) '\_' dapiorigname(3) '\_' dapiorigname(5:end-16)]);
        subplot(2,2,2); imagesc(computeMIP(registeredData.DapiOriginal));
        title(['Registered data ' dapiorigname(1) '\_' dapiorigname(3) '\_' dapiorigname(5:end-16)]);
        subplot(2,2,3); imagesc(computeMIP(processedData.DapiSegm));
        title(['Segmented data ' dapiorigname(1) '\_' dapiorigname(3) '\_' dapiorigname(5:end-16)]);
        subplot(2,2,4); imagesc(computeMIP(registeredData.DapiSegm));
        title(['Registered segmented data ' dapiorigname(1) '\_' dapiorigname(3) '\_' dapiorigname(5:end-16)]);
        savefig([p.resultsPath '\' dapiorigname(1:10) '_registration.fig'])
figure; subplot(2,2,1); imagesc(computeMIP(processedData.GFP));
        title(['Original data ' gfporigname(1) '\_' gfporigname(3) '\_' gfporigname(5:end-16)]);
        subplot(2,2,2); imagesc(computeMIP(registeredData.GFP));
        title(['Registered data ' gfporigname(1) '\_' gfporigname(3) '\_' gfporigname(5:end-16)]);
        subplot(2,2,3); imagesc(computeMIP(processedData.landmark));
        title(['Segmented data ' gfporigname(1) '\_' gfporigname(3) '\_' gfporigname(5:end-16)]);
        subplot(2,2,4); imagesc(computeMIP(registeredData.landmark));
        title(['Registered segmented data ' gfporigname(1) '\_' gfporigname(3) '\_' gfporigname(5:end-16)]);
        savefig([p.resultsPath '\' gfporigname(1:9) '_registration.fig'])
figure; subplot(2,2,1); imagesc(computeMIP(processedData.mesodermOriginal));
        title(['Original data ' mesodermorigname(1) '\_' mesodermorigname(3) '\_' mesodermorigname(5:end-16)]);
        subplot(2,2,2); imagesc(computeMIP(registeredData.mesodermOriginal));
        title(['Registered data ' mesodermorigname(1) '\_' mesodermorigname(3) '\_' mesodermorigname(5:end-16)]);
        subplot(2,2,3); imagesc(computeMIP(processedData.mesodermSegm));
        title(['Segmented data ' mesodermorigname(1) '\_' mesodermorigname(3) '\_' mesodermorigname(5:end-16)]);
        subplot(2,2,4); imagesc(computeMIP(registeredData.mesodermSegm));
        title(['Registered segmented data ' mesodermorigname(1) '\_' mesodermorigname(3) '\_' mesodermorigname(5:end-16)]);
        savefig([p.resultsPath '\' mesodermorigname(1:14) '_registration.fig'])
figure; subplot(2,2,1); imagesc(computeMIP(processedData.ectoendoOriginal));
        title(['Original data ' ectoendoorigname(1) '\_' ectoendoorigname(3) '\_' ectoendoorigname(5:end-16)]);
        subplot(2,2,2); imagesc(computeMIP(registeredData.ectoendoOriginal));
        title(['Registered data ' ectoendoorigname(1) '\_' ectoendoorigname(3) '\_' ectoendoorigname(5:end-16)]);
        subplot(2,2,3); imagesc(computeMIP(processedData.ectoendoSegm));
        title(['Segmented data ' ectoendoorigname(1) '\_' ectoendoorigname(3) '\_' ectoendoorigname(5:end-16)]);
        subplot(2,2,4); imagesc(computeMIP(registeredData.ectoendoSegm));
        title(['Registered segmented data ' ectoendoorigname(1) '\_' ectoendoorigname(3) '\_' ectoendoorigname(5:end-16)]);
        savefig([p.resultsPath '\' ectoendoorigname(1:14) '_registration.fig'])

% Save the registered data
filename_registered_data = [p.resultsPath '\' dapiorigname(1:6) '_registered_data'];
save(filename_registered_data,'registeredData');