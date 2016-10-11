%% INITIALIZATION

% add current folder and subfolders to path variable
addpath(genpath('./..'));

%% SET PARAMETERS

dataPath = '../data/tilting_adjustments_first_priority';
resolution = [1.29, 1.29, 20];
scale = 0.5;
samples_sphere = 64;
samples_cube = 256;
landmarkCharacteristic = 'middle';
pstar_reference = [0; 0; -1];
vstar_reference = [1; 0; 0];

%% LOAD DATA

% get filenames of STK files in selected folder
fileNames = getSTKfilenames(dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannels(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

% adjust resolution according to scale parameter
resolution(1:2) = resolution(1:2) / scale;

%% MAIN LOOP

% process all existing data sequentially
for experiment=1:numberOfExperiments
   
    % get data of current experiment
    experimentData = loadExperimentData(allValidExperiments(experiment,:), dataPath);
    experimentData = experimentData.Data_1;
    
    % preprocess and rescale data
    processedData = preprocessData(experimentData, scale);
        
    % segment data
    disp('Segmenting GFP channel...');
    landmark = segmentGFP(processedData.GFP, resolution);
    disp('Segmenting mCherry channel...');
    [cells, cellCoordinates] = segmentCells(processedData.mCherry, resolution);
    
    % check the orientation of the embryo and flip to be head-right
    headOrientation = determineHeadOrientation(computeMIP(landmark));
    if strcmp(headOrientation, 'left')
        disp('Rotating data...');
        [processedData, landmark, cells, cellCoordinates] = ...
            flipOrientation(processedData, landmark, cells, cellCoordinates);
    end
    
    % estimate embryo surface by fitting an ellipsoid
    disp('Estimating embryo surface...');
    ellipsoid = estimateEmbryoSurface(processedData.Dapi, resolution);
    
    
    disp('Compute transformation from optimal ellipsoid...');
    transformationMatrix = computeTransformationMatrix(ellipsoid);
    
    % DEBUG
    disp('Transform data for validity check...');
    [transformedData.Dapi, transformedResolution] = ...
        transformVoxelData(processedData.Dapi, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    [transformedData.GFP, ~] = ...
        transformVoxelData(processedData.GFP, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    [transformedData.mCherry, ~] = ...
        transformVoxelData(processedData.mCherry, resolution, transformationMatrix, ellipsoid.center, samples_cube);
    
    % project landmark onto unit sphere
    disp('Projecting landmark onto embryo surface...');
    [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
        projectLandmarkOnSphere(landmark, resolution, ellipsoid, samples_sphere);
    
    % 
    disp('Registering data...');
    %regData = compRegData(landmark, samples, resolution, radii, center, axes);
    
    registerLandmark(landmarkCoordinates, pstar_reference, vstar_reference, landmarkCharacteristic);
    
end



%% VISUALIZATION %%
close all;
% -- Data -- %
figure(1), imagesc(max(h.data.(char(h.fieldnames(h.nData))).GFP,[],3)),title('GFP Channel MIP');
figure(2), imagesc(max(h.data.(char(h.fieldnames(h.nData))).mCherry,[],3)),title('mCherry Channel MIP');

drawnow,pause();
% -- Preprocessing -- %

figure(1),clf, imagesc(max(predata.GFP,[],3)),title('GFP Channel MIP removed background');
figure(2),clf, imagesc(max(predata.mCherry,[],3)),title('mCherry Channel MIP removed background');

drawnow,pause();
% -- Segmentation -- %

figure(1),clf,imagesc(max(predata.GFP,[],3)),hold on,
contour(max(h.SegData.(char(h.fieldnames(h.nData))).landmark,[],3), 'r', 'LineWidth', 2),
title('Segmentation of the embryo shape');
figure(2),clf,imagesc(max(predata.mCherry,[],3)),hold on,
contour(max(h.SegData.(char(h.fieldnames(h.nData))).cells,[],3),  'r', 'LineWidth', 2),
title('Segmentation of the cells');
drawnow,pause();

figure(3), scatter3(h.SegData.(char(h.fieldnames(h.nData))).regData(1,:),...
    h.SegData.(char(h.fieldnames(h.nData))).regData(2,:),...
    h.SegData.(char(h.fieldnames(h.nData))).regData(3,:)),
hold on,
title('Segmentation of the embryo on a sphere'),
xlim([-1,1]),ylim([-1,1]),zlim([-1,1]),view(0,-90);

drawnow,pause();

% Orientation of the head
% Generate histogram of column sums

figure(4),
plot(1:size(h.SegData.(char(h.fieldnames(h.nData))).landmark,2),colHistogram), 
title(['Column histogram, orientation of the head: ',headOrientation]);
if strcmp(headOrientation,'left')
   drawnow,pause();
   figure(4),clf,
    plot(1:size(h.SegData.(char(h.fieldnames(h.nData))).landmark,2),fliplr(colHistogram)), 
    title('Column histogram, orientation of the head: right');
end
drawnow,pause();

%%
% -- Registration -- %

% show the other before and after rotation
regDataRef = h.SegData.(char(h.fieldnames(h.nRefData))).regData;
pref = h.SegData.(char(h.fieldnames(h.nRefData))).pstar;
vref = h.SegData.(char(h.fieldnames(h.nRefData))).vstar;

figure(5),
for i=2:5
    subplot(2,2,i-1)
    scatter3(h.SegData.(char(h.fieldnames(i))).regData(1,:),...
        h.SegData.(char(h.fieldnames(i))).regData(2,:),...
        h.SegData.(char(h.fieldnames(i))).regData(3,:)),hold on,
    scatter3(h.SegData.(char(h.fieldnames(i))).centCoords(1,:),...
        h.SegData.(char(h.fieldnames(i))).centCoords(2,:),...
        h.SegData.(char(h.fieldnames(i))).centCoords(3,:),'x','m')
    xlim([-1,1]),ylim([-1,1]),zlim([-1,1]),title('Embryo');
end
drawnow,pause();

figure(5),
for i=2:5
    subplot(2,2,i-1)
    title('Drawing regression line.');
    T = 0:0.01:2*pi;
    G = geodesicFun(h.SegData.(char(h.fieldnames(i))).pstar,...
        h.SegData.(char(h.fieldnames(i))).vstar);
    rL = G(T);
    plot3(rL(1,:),rL(2,:),rL(3,:),'r')
end
drawnow,pause();

figure(5),
for i=2:5
    subplot(2,2,i-1)
    title('Getting head coordinate.')
    scatter3(h.SegData.(char(h.fieldnames(i))).pstar(1),...
        h.SegData.(char(h.fieldnames(i))).pstar(2),...
        h.SegData.(char(h.fieldnames(i))).pstar(3),'*','r');
end
drawnow,pause();

figure(5),
for i=2:5
    subplot(2,2,i-1)
    title('Show reference embryo');
    scatter3(regDataRef(1,:),regDataRef(2,:),regDataRef(3,:),'x','g')
end
drawnow,pause();

G = geodesicFun(pref,vref);
rLRef = G(T);
figure(5),
for i=2:5
    subplot(2,2,i-1)
    title('Drawing regression line.');
    plot3(rLRef(1,:),rLRef(2,:),rLRef(3,:),'g')
end
drawnow,pause();

figure(5),
for i=2:5
    subplot(2,2,i-1)
    title('Getting head coordinate.')
    scatter3(pref(1),pref(2),pref(3),'b','*');
end
drawnow,pause();

figure(5),
for i=2:5
    subplot(2,2,i-1),cla,
    Rp = h.SegData.(char(h.fieldnames(i))).Rp;
    Ra = h.SegData.(char(h.fieldnames(i))).Ra;
    Rv = h.SegData.(char(h.fieldnames(i))).Rv;
    title('Rotating p onto the reference')
    regData_r = Rp*h.SegData.(char(h.fieldnames(i))).regData;
    scatter3(regData_r(1,:),regData_r(2,:),regData_r(3,:),'r');
    plot3(rLRef(1,:),rLRef(2,:),rLRef(3,:),'g')
    scatter3(pref(1),pref(2),pref(3),'g','*');
    scatter3(regDataRef(1,:),regDataRef(2,:),regDataRef(3,:),'x','g')
    p = Rp*h.SegData.(char(h.fieldnames(i))).pstar;
    v = Rv*h.SegData.(char(h.fieldnames(i))).vstar;
    centCoords = Rp*h.SegData.(char(h.fieldnames(i))).centCoords;
    scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:),'x','m')
    scatter3(p(1),p(2),p(3),'*','r');
    G = geodesicFun(h.SegData.(char(h.fieldnames(i))).pstar,...
        h.SegData.(char(h.fieldnames(i))).vstar);
    rL = G(T);
    rL = Rp*rL;
    plot3(rL(1,:),rL(2,:),rL(3,:));
end
drawnow,pause();

figure(5),
for i=2:5
    subplot(2,2,i-1),cla,
    Rp = h.SegData.(char(h.fieldnames(i))).Rp;
    Ra = h.SegData.(char(h.fieldnames(i))).Ra;
    Rv = h.SegData.(char(h.fieldnames(i))).Rv;
    title('Rotating regression line onto reference')
    regData_r = Ra*Rp*h.SegData.(char(h.fieldnames(i))).regData;
    scatter3(regData_r(1,:),regData_r(2,:),regData_r(3,:),'r');
    plot3(rLRef(1,:),rLRef(2,:),rLRef(3,:),'g')
    scatter3(pref(1),pref(2),pref(3),'g','*');
    scatter3(regDataRef(1,:),regDataRef(2,:),regDataRef(3,:),'x','g')
    p = Ra*Rp*h.SegData.(char(h.fieldnames(i))).pstar;
    centCoords = Ra*Rp*h.SegData.(char(h.fieldnames(i))).centCoords;
    scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:),'x','m')
    scatter3(p(1),p(2),p(3),'*','r');
    G = geodesicFun(h.SegData.(char(h.fieldnames(i))).pstar,...
        h.SegData.(char(h.fieldnames(i))).vstar);
    rL = G(T);
    rL = Ra*Rp*rL;
    plot3(rL(1,:),rL(2,:),rL(3,:));
end

% -- Heatmap -- %