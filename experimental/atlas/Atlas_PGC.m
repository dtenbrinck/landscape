%% INITIALIZATION
clear; clc; close all;

% add path for parameter setup
root_dir = fileparts(fileparts(pwd()));
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('processing', root_dir);

% manual set resolution parameter
manRes = [0,0,0];

%% PREPARE RESULTS DIRECTORY
checkDirectory(p.resultsPath);

%% LOAD DATA
% Select the file
dnameAccumulator = uigetfile(p.dataPath,'Please select Accumulator.mat!'); % Select all files to see the data
dnameEmbryo = uigetfile(p.dataPath,'Please select the atlas data!'); % Select all files to see the data
load([p.dataPath '\' dnameAccumulator]);
load([p.dataPath '\' dnameEmbryo]);

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;

accumulator = accumulator(1:256,1:256,1:256);
%% Compute PGC Tissue
PGCmesoderm = accumulator .* intersection_registration_threshold.mesoderm;
PGCendoderm = accumulator .* intersection_registration_threshold.endoderm;
PGCectoderm = accumulator .* intersection_registration_threshold.ectoderm;
PGClandmark = accumulator .* intersection_registration_threshold.landmark;
PGCDapi = accumulator .* intersection_registration_threshold.Dapi;

PGCallNumber = find(accumulator);
PGCmesodernNumber = find(PGCmesoderm);
PGCendodermNumber = find(PGCendoderm);
PGCectodermNumber = find(PGCectoderm);
PGClandmarkNumber = find(PGClandmark);
PGCDapiNumber = find(PGCDapi);

%% Prüfen, ob die Atlasdaten sich doppeln und somit Zellen doppelt gezählt werden
a = find(intersection_registration_threshold.mesoderm .* intersection_registration_threshold.ectoderm);


% %% Plots
% figure;imagesc(computeMIP(accumulator))
% figure;imagesc(computeMIP(PGCDapi))
% figure;imagesc(computeMIP(PGCectoderm))
% figure;imagesc(computeMIP(PGCendoderm))
% figure;imagesc(computeMIP(PGClandmark))
% figure;imagesc(computeMIP(PGCmesoderm))

%% Plot Vergleich
figure;subplot(1,3,1);imagesc(computeMIP(accumulator));
title('Accumulator.mat Epi'); axis tight; axis equal;
subplot(1,3,2);imagesc(computeMIP(intersection_registration_threshold.Dapi));
title('Atlas Dapi'); axis tight; axis equal;
subplot(1,3,3);imagesc(computeMIP(PGCDapi));
title('Schnitt Accumulator und Atlas'); axis tight; axis equal;

figure;subplot(1,3,1);imagesc(computeMIP(accumulator));
title('Accumulator.mat Epi'); axis tight; axis equal;
subplot(1,3,2);imagesc(computeMIP(intersection_registration_threshold.ectoderm));
title('Atlas ectoderm'); axis tight; axis equal;
subplot(1,3,3);imagesc(computeMIP(PGCectoderm));
title('Schnitt Accumulator und Atlas'); axis tight; axis equal;

figure;subplot(1,3,1);imagesc(computeMIP(accumulator));
title('Accumulator.mat Epi'); axis tight; axis equal;
subplot(1,3,2);imagesc(computeMIP(intersection_registration_threshold.endoderm));
title('Atlas endoderm'); axis tight; axis equal;
subplot(1,3,3);imagesc(computeMIP(PGCendoderm));
title('Schnitt Accumulator und Atlas'); axis tight; axis equal;

figure;subplot(1,3,1);imagesc(computeMIP(accumulator));
title('Accumulator.mat Epi'); axis tight; axis equal;
subplot(1,3,2);imagesc(computeMIP(intersection_registration_threshold.landmark));
title('Atlas landmark'); axis tight; axis equal;
subplot(1,3,3);imagesc(computeMIP(PGClandmark));
title('Schnitt Accumulator und Atlas'); axis tight; axis equal;

figure;subplot(1,3,1);imagesc(computeMIP(accumulator));
title('Accumulator.mat Epi'); axis tight; axis equal;
subplot(1,3,2);imagesc(computeMIP(intersection_registration_threshold.mesoderm));
title('Atlas mesoderm'); axis tight; axis equal;
subplot(1,3,3);imagesc(computeMIP(PGCmesoderm));
title('Schnitt Accumulator und Atlas'); axis tight; axis equal;

figure;image((accumulator - (PGCmesoderm + PGCendoderm + PGCectoderm + PGClandmark))>0);
title('rest'); axis tight; axis equal;
