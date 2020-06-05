%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);
        %other parameters:
%resolution = [1.29, 1.29, 10];
landmarkCharacteristic = 0;
weight = 0;
reference_point = [-1; 0; 0]; 
reference_vector = [0; 0; -1];
%min_radius = 0.74464;
%max_radius = 0.80544;
teta  = 1*0.174533; % x*10 degrees
slices = 20; 

%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(strcmp(fileNames,'ParameterProcessing.mat')) = [];
fileNames(strcmp(fileNames,'ParameterHeatmap.mat')) = [];
fileNames(strcmp(fileNames,'HeatmapAccumulator.mat')) = [];

if p.random == 1
    fileNames = drawRandomNames(fileNames,p.numberOfRandom);
end
% Get number of experiments
numberOfResults = numel(fileNames);

% Check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(resultsPathAccepted);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for generating heat map.']);
end

%% MAIN CODE

amountOfNucleis = zeros(slices,1);
radii = computeLandmarkShell(p, fileNames, numberOfResults);

for result = 1:numberOfResults
    
    %Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    %project Landmark on Sphere and calculate great circle (pstar,vstar)
    landmarkPosition = double(gatheredData.processed.landmark);
    [sphereCoordinates, landmarkCoordinates, landmarkOnSphere] = ...
            projectLandmarkOnSphere(landmarkPosition, p.resolution, gatheredData.processed.ellipsoid, p.samples_sphere); 
    [pstar,vstar] = computeRegression_new(landmarkCoordinates','false');
    
    %for debugging
    %visualizeProjectedLandmark(sphereCoordinates, landmarkOnSphere);
    
    % Tilt refpstar onto the specified position
    [pstar,vstar] = getCharPos_daniel(pstar,vstar,landmarkCoordinates',landmarkCharacteristic,weight);
	pstar = pstar/norm(pstar);
    vstar = vstar/norm(vstar);
    
    % Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
    [Rp,~,~,~,vAngle]...
    = rotateGreatCircle(pstar,vstar,reference_point,reference_vector);

    % Rotationmatrix: Rotates the regression line onto the reference line
	Ra = rotAboutAxis(vAngle,reference_point);

    transformation = Ra * Rp;

    pstar = Rp*pstar;
    vstar = Ra*Rp*vstar;
    transformedCoordinates = transformation * landmarkCoordinates';
   
    %get points on surface that define equally large slices of landmark (from head to tail). We
    %will later calculate the cell density in each of the slices
    pointsOnSurface = zeros(slices,3);
    for i = 0:slices
    [pstar,vstar] = getCharPos_daniel(pstar,vstar,transformedCoordinates,landmarkCharacteristic,i* 1/slices);
    pstar = pstar/norm(pstar);
    vstar = vstar/norm(vstar);
    pointsOnSurface(i+1,:) = pstar; 
    end
  
    nucleiCoords = gatheredData.registered.nucleiCoordinates;
    nucleiCoords = nucleiCoords';
    
    %TEST
    %nucleiCoords = gatheredData.registered.landmarkCentCoords; %eigentlich landmark Coords
    %nucleiCoords = nucleiCoords'; 
    
    %calculate [azimuth/phi, elevation/teta, radius] of pointsOnSurface (spherical
    %coordinates)
    for i = 1:slices+1
    [pointsOnSurface(i,1), pointsOnSurface(i,2), pointsOnSurface(i,3)] = cart2sph(pointsOnSurface(i,1),pointsOnSurface(i,2),pointsOnSurface(i,3));
    end
    %calculate [azimuth/phi, elevation/teta, radius] of nucleiCoords (spherical
    %coordinates)
    for i = 1:size(nucleiCoords,1)
    [nucleiCoords(i,1), nucleiCoords(i,2), nucleiCoords(i,3)] = cart2sph(nucleiCoords(i,1),nucleiCoords(i,2),nucleiCoords(i,3));
    end
    
    %calculate amount of nucleis inside slices and landmark area defined by
    %[azimuth/phi, elevation/teta, radius] 
    %TODO: FIX PROBLEMS ON BORDERS OF EDGES
    min_radius = radii(2, result);
    max_radius = radii(1, result);
    area = double.empty(0,3);
    for slice = 1:slices
        for i = 1: size(nucleiCoords,1)
            %check boundaries for azimuth, elevation, radius
           if abs(nucleiCoords(i,1)) <= pi/2 
               if abs(nucleiCoords(i,2)) > abs(pointsOnSurface(slice+1,2)) && abs(nucleiCoords(i,2)) <= abs(pointsOnSurface(slice,2)) && abs(nucleiCoords(i,1)) <= teta && nucleiCoords(i,3)>= min_radius && nucleiCoords(i,3) <= max_radius  
                    amountOfNucleis(slice) = amountOfNucleis(slice) +1;
                    [nucleiCoords(i,1), nucleiCoords(i,2), nucleiCoords(i,3)] = sph2cart(nucleiCoords(i,1),nucleiCoords(i,2),nucleiCoords(i,3));
                    area = vertcat(area, nucleiCoords(i,:));
               end 
            end  
           % if abs(nucleiCoords(i,1)) <= pi/2 && nucleiCoords(i,2) >= 0
             %  if abs(nucleiCoords(i,2)) > abs(pointsOnSurface(slice,2)) && abs(nucleiCoords(i,2)) < abs(pointsOnSurface(slice+1,2)) && abs(nucleiCoords(i,1)) <= teta && nucleiCoords(i,3)>= min_radius && nucleiCoords(i,3) <= max_radius  
                %    amountOfNucleis(slice) = amountOfNucleis(slice) +1;
                   % [nucleiCoords(i,1), nucleiCoords(i,2), nucleiCoords(i,3)] = sph2cart(nucleiCoords(i,1),nucleiCoords(i,2),nucleiCoords(i,3));
                  %  area = vertcat(area, nucleiCoords(i,:));
              % end
            %end  
            if   abs(nucleiCoords(i,1)) > pi/2 
                if abs(nucleiCoords(i,2)) <= abs(pointsOnSurface(slice +1,2)) && abs(nucleiCoords(i,2)) > (pointsOnSurface(slice,2)) && abs(nucleiCoords(i,1)) >= pi-teta && nucleiCoords(i,3)>= min_radius && nucleiCoords(i,3) <= max_radius 
                    amountOfNucleis(slice) = amountOfNucleis(slice) +1;
                    [nucleiCoords(i,1), nucleiCoords(i,2), nucleiCoords(i,3)] = sph2cart(nucleiCoords(i,1),nucleiCoords(i,2),nucleiCoords(i,3));
                    area = vertcat(area, nucleiCoords(i,:));
                end
            end   
                   
        end
    
    %for debugging:   
    if result < 2
    x = pointsOnSurface;
    for i = 1:size(pointsOnSurface,1)
    [x(i,1),x(i,2),x(i,3)]= sph2cart(x(i,1),x(i,2),x(i,3)); 
    end
    landmarkCoords = gatheredData.registered.landmarkCentCoords;
    landmarkCoords = landmarkCoords';
    figure;
    scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
    hold on
    scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
    hold on
    scatter3(area(:,1),area(:,2),area(:,3), 100,'*');
    hold on 
    scatter3(x(:,1),x(:,2),x(:,3), 100)
    view(0,90);
    drawnow
    hold off
    end
    
    end
       
end

plotting = 1;
if plotting == 1
% plot results
amountHeadside=0; %will have amount of cells in head mesoderm (first 55% of landmark)
amountTailside=0; %will have amount of cells in notochord (last 45% of landmark) 
for i = 1:11
    amountHeadside = amountHeadside + amountOfNucleis(i);
end 

for i = 11:20
    amountTailside = amountTailside + amountOfNucleis(i);
end 

amountTotal = amountHeadside + amountTailside;

amountOfNucleis = 1/amountTotal * amountOfNucleis;
figure
plot(amountOfNucleis);

figure
x = [ 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95];
bar(x,amountOfNucleis');

amountHeadside = amountHeadside * 50/45 *1/amountTotal;
amountTailside = amountTailside *50/55 *1/amountTotal;
c = categorical({'head mesoderm (0-45%)','notochord (45-100%)',});
figure
bar(c,[amountHeadside,amountTailside]);
end
