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
datanames = {'1.mat';'11.mat';'12.mat';'13.mat'};

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
SegmentationData = genSegData(Xs,Ys,Zs,Xc,Yc,Zc,datanames,resolution,scale);

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
    = computeRegression(SegmentationData.(['Data_',refDataset]).GFPOnSphere, Xs, Ys, Zs, 'true');

fprintf('Setting the reference p* and v*.\n');

% Update SegmentationData
SegmentationData.(['Data_',refDataset]).pstar = refpstar;
SegmentationData.(['Data_',refDataset]).vstar = refvstar;
SegmentationData.(['Data_',refDataset]).regData = regData;

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
        = computeRegression(SegmentationData.(fieldname).GFPOnSphere, Xs,Ys,Zs,vis_regr);
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
    SegmentationData.(fieldname).centCoords ...
        = Ra*Rp*SegmentationData.(fieldname).centCoords;
    
    % Update field
    SegmentationData.(fieldname).Rp = Rp;
    SegmentationData.(fieldname).Rv = Rv;
    SegmentationData.(fieldname).Ra = Ra;
    SegmentationData.(fieldname).pstar = pstar;
    SegmentationData.(fieldname).vstar = vstar;
    SegmentationData.(fieldname).pstar_r = pstar_r;
    SegmentationData.(fieldname).vstar_r = vstar_r;
    SegmentationData.(fieldname).vAngle = vAngle;
    SegmentationData.(fieldname).regData = regData;
    SegmentationData.(fieldname).regData_r = regData_r;
    
    % Visualize Registration
    if vis_regist == true;
        showRegist(SegmentationData.(['Data_',refDataset]),...
            SegmentationData.(fieldname),['Data_',refDataset],fieldname);
    end
end

fprintf('Registration Done!\n');

% Main registration %



%% 4. Compute the heatmap