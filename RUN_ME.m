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

% Generate segmentation data.
SegmentationData = genSegData(Xs,Ys,Zs,Xc,Yc,Zc,datanames,resolution,scale);

%% 2. User interaction
% Just to turn the embryo s.t. the head is in the right direction.
% Maybe wont need this later if the biologists find good characteristics.
fprintf('\n\nUser interaction: \n');
fprintf('Choose which dataset should be the reference dataset?\n');
refDataset = char(datanames(1));
refDataset = refDataset(1:end-4);
fprintf('Default selected. Starting with the first dataset.\n');
%% 3. Registration

fprintf('Starting registration: \n');
fprintf('Computing regressions...\n');

% Compute the spherical regression for the rest of the datasets

for i=1:size(datanames,1)
    fprintf(['Computing regression for dataset ',num2str(i),' of ',num2str(size(datanames,1)),'.\n']);
    
    % Get the data that is projected onto the sphere
    dataName = char(datanames(i));
    dataName = dataName(1:end-4);
    fieldname = ['Data_',dataName];
    regData = [(round(Xs(SegmentationData.(fieldname).GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Ys(SegmentationData.(fieldname).GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Zs(SegmentationData.(fieldname).GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
    regData = unique(regData','rows')';
    SegmentationData.(fieldname).regData = regData;
    % Set options
    options = optimoptions('fmincon','Display','off','Algorithm','sqp');
    
    % Compute spherical regression
    [SegmentationData.(fieldname).pstar,SegmentationData.(fieldname).vstar] ...
        = sphericalRegression3D(regData,[1;0;0],[0;0;-1],options,'true');
    
    % Registration part %
    if i > 1
        % Rotate great circle
        fprintf('Rotate great circle onto the reference circle.\n');
        [SegmentationData.(fieldname).Rp,SegmentationData.(fieldname).Rv, ...
            SegmentationData.(fieldname).pstar_r,SegmentationData.(fieldname).vstar_r,...
            SegmentationData.(fieldname).vAngle]...
            = rotateGreatCircle(SegmentationData.(fieldname).pstar,...
            SegmentationData.(fieldname).vstar,refpstar,refvstar);
        
    elseif i == 1
        % Set as reference values
        refpstar = SegmentationData.(['Data_',refDataset]).pstar;
        refvstar = SegmentationData.(['Data_',refDataset]).vstar;
    end
    
end

fprintf('Registration Done!\n');

% Main registration %



%% 4. Compute the heatmap