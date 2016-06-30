%% Run Functions for the heat map
% This will be replaced by the heatmap function later on

%% Introduction:
% Main script for registration of confocal microscopy data of small fish
% embryos.
%
% Data: We assume the data to be already converted from *.STK files given
% by the biologists to *.mat files containing a struct with three fields:
% data
%     .Dapi    -> fluorescence of nuclei near the embryo membrane
%     .GFP     -> fluorescence of anatomic structure denoted as 'landmark'
%     .mCherry -> fluorescence of labeled stem cells in embryo
%
% One is interested in the distribution of the cells in the mCherry data.
% We use the information in the Dapi channel to estimate the shape of the
% embryo and the landmark in the GPF channel for registration of different
% specimen.
%
%   Copyright: Daniel Tenbrinck, Fjedor Gaede
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: daniel.tenbrinck@wwu.de
%   Date: 2016/02/18

%% 0. Initialization

% General init: %

% Tidy up memory and windows before starting
clear; close all; clc;

% Get all subdirectories
addpath(genpath(pwd));

% Value and variable init: %

% Visualize 
vis_regist = true;
vis_regr = 'true';


% Set rescaling factor
scale = 0.5;

% Set resolution for data in micrometers (given by biologists)
resolution = [1.29/scale, 1.29/scale, 20];

% Set the sample rate (will be changeable for user later)
samples = 64;

% Name of the datasets (Load out of GUI later)
datanames = {'1.mat';'11.mat';'12.mat'};

% Sample the unit sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Sample the unit cube
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));

%% 1. Segmentation and projection of all data sets
fprintf('Starting segmentation...\n');
% Generate segmentation data.
SegData = genSegData(Xs,Ys,Zs,Xc,Yc,Zc,datanames,resolution,scale);

%% 2. User interaction
% Just to turn the embryo s.t. the head is in the right direction.
% Maybe wont need this later if the biologists find good characteristics.
fprintf('\n\nUser interaction: \n');
fprintf('Choose which dataset should be the reference dataset?\n');
refDataset = char(datanames(3));
refDataset = refDataset(1:end-4);
datanames(3) = [];
fprintf('Default selected. Starting with the first dataset.\n');
%% 3. Registration

fprintf('Starting registration: \n');
fprintf(['Initializing the reference data set ',refDataset,'.mat... \n']);

% Initialize the reference data set.
[refpstar, refvstar,regData] ...
    = computeRegression(SegData.(['Data_',refDataset]).GFPOnSphere, Xs, Ys, Zs, 'true');

fprintf('Setting the reference p* and v*.\n');

% Update SegData
SegData.(['Data_',refDataset]).pstar = refpstar;
SegData.(['Data_',refDataset]).vstar = refvstar;
SegData.(['Data_',refDataset]).regData = regData;

fprintf('Initialization done!\n');
% Compute the spherical regression for the rest of the datasets and
% register them.

fprintf(['Starting registration of the data sets to the reference dataset: ',refDataset,'... \n'])

for i=1:size(datanames,1)
    fprintf(['Computing regression for dataset ',num2str(i),' of ',num2str(size(datanames,1)),'...']);
    
    % Get the data that is projected onto the sphere
    dataName = char(datanames(i));
    dataName = dataName(1:end-4);
    fieldname = ['Data_',dataName];
    
    % Compute regression
    [pstar,vstar, regData] ...
        = computeRegression(SegData.(fieldname).GFPOnSphere, Xs,Ys,Zs,vis_regr);
    fprintf('Done!\n');
    
    % Registration of the data set
    fprintf('Register data set onto reference dataset.\n');
    
    % Rotationmatrix: Rotate the great circle s.t. pstar is on refpstar
    [Rp,Rv,pstar_r,vstar_r,vAngle]...
        = rotateGreatCircle(pstar,vstar,refpstar,refvstar);
    
    % Rotationmatrix: Rotates the regression line onto the reference line
    Ra = rotAboutAxis(vAngle,refpstar);
    
    % Rotate data set and cell coordinates
    regData_r = Ra*Rp*regData;
    SegData.(fieldname).centCoords ...
        = Ra*Rp*SegData.(fieldname).centCoords;
    
    % Update field
    SegData.(fieldname).Rp = Rp;
    SegData.(fieldname).Rv = Rv;
    SegData.(fieldname).Ra = Ra;
    SegData.(fieldname).pstar = pstar;
    SegData.(fieldname).vstar = vstar;
    SegData.(fieldname).pstar_r = pstar_r;
    SegData.(fieldname).vstar_r = vstar_r;
    SegData.(fieldname).vAngle = vAngle;
    SegData.(fieldname).regData = regData;
    SegData.(fieldname).regData_r = regData_r;
    
    % Visualize Registration
    if vis_regist == true;
        showRegist(SegData.(['Data_',refDataset]),...
            SegData.(fieldname),['Data_',refDataset],fieldname);
    end
end

fprintf('Registration Done!\n');





%% 4. Compute the heatmap

% PUT INTO FUNCTIONS!
% We will give 3 different heatmaps.
% 1. slice by slice
% 2. 3D
% 3. projected (as a 2d image and a 3d block diagramm the circle must be
% drawn because the heatmap is for the circle)

% Get all cell coordinates
fieldNames = fieldnames(SegData);
allCentCoords = [];
for i = 1:size(fieldNames,1)
   allCentCoords = horzcat(allCentCoords,SegData.(char(fieldNames(i))).centCoords);
end
numOfCells = size(allCentCoords,2);
sizeLandmark = size(SegData.(fieldNames{1}).landmark);

% Fit the coordinates onto the 64x64x64 sample grid

% 1. SbS-Heatmap
% User should be able to choose between different samplings.
% 1.1 Sampling by value of samples
[samCoordsG,samCoordsU] = fitOnSamSphere(allCentCoords,samples);
sizeNH = 8;
typeNH = 'sphere';
SbSMat = compDens3D(samples,samCoordsG,sizeNH,typeNH);
% showSbS(SbSMat);
% 1.2 Sampling in original data sampling
[samCoordsG,samCoordsU] = fitOnSamSphere(allCentCoords,sizeLandmark);
SbSMat3 = compDens3D(sizeLandmark,samCoordsG,sizeNH,typeNH);
% showSbS(SbSMat3);

% 1.3 Contour
% 2. 3D
% 2.1 Should just draw the points

figure, scatter3(samCoordsG(1,:),samCoordsG(2,:),samCoordsG(3,:)),
title('Sampled Coordinates on the sampling grid.');
figure, scatter3(samCoordsU(1,:),samCoordsU(2,:),samCoordsU(3,:)),
title('Sampled Coordinates on the sampled on the unit sphere.');
% 2.2 Should get a value that shows the different densities
% 2.3 Cool 3d cloud.
% User should pick between different layers.
% Also if it should be smoothed or not.
SbSMat2 = smooth3(SbSMat);
figure, IS1 = isosurface(SbSMat2,1);
hold on
IS2 = isosurface(SbSMat2,2);
IS3 = isosurface(SbSMat2,3);
IS4 = isosurface(SbSMat2,4);
p1 = patch(IS1,'FaceColor','blue','FaceAlpha',0.2,'EdgeColor','none');
p2 = patch(IS2,'FaceColor','green','FaceAlpha',0.3,'EdgeColor','none');
p3 = patch(IS3,'FaceColor','yellow','FaceAlpha',0.4,'EdgeColor','none');
p4 = patch(IS4,'FaceColor','red','FaceAlpha',1,'EdgeColor','none');
isonormals(SbSMat2,p1)
isonormals(SbSMat2,p2)
isonormals(SbSMat2,p3)
isonormals(SbSMat2,p4)
view(3)
daspect([1 1 1])
axis tight
camlight
camlight(-80,-10)
lighting gouraud
title('Good?');
hold off;


% 3. Projected
% 3.1 As a map
prMat = sum(SbSMat,3);
figure, imagesc(prMat);
colormap('jet')
% 3.1.1 Shown as bars. in slice direction. So you can see which slices are
% good. Histogramm
slicesMat = permute(sum(sum(SbSMat)),[3,1,2]);
figure, bar(slicesMat), title('Density distribution in the slices');
% 3.1.2 Histogram x direction
slicesMat = sum(sum(SbSMat,1),3)';
figure, bar(slicesMat), title('Density distribution in the slices');
% 3.1.3 Histogramm in y direction
slicesMat = sum(sum(SbSMat,2),3);
figure, bar(slicesMat), title('Density distribution in the slices');
% 3.2 As a 3d map 
% 3.2.1 As Bars in 3d
figure, b=bar3(prMat);
% 3.2.2 With color depending on density.
colormap('jet')
for k = 1:length(b)
    zdata = b(k).ZData;
    b(k).CData = zdata;
    b(k).FaceColor = 'interp';
end


