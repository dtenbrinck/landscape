%%% Create intersection_registration without threshold

% INITIALIZATION
clear; clc; close all;

% load necessary variables
root_dir = fileparts(fileparts(pwd));
addpath([root_dir '/parameter_setup/']);
p = initializeScript('processing', root_dir);
p.resolution = [1.1512, 1.1512, 5];   % 30 percent scale

d1_ecto_name = uigetfile(p.dataPath,'Please select the d1 ecto data!'); % Select all files to see the data
d1_endo_name = uigetfile(p.dataPath,'Please select the d1 endo data!');
d3_ecto_name = uigetfile(p.dataPath,'Please select the d3 ecto data!');
d3_endo_name = uigetfile(p.dataPath,'Please select the d3 edoo data!');


d1_ecto = load([p.dataPath '/' d1_ecto_name]);
d1_endo = load([p.dataPath '/' d1_endo_name]);
d3_ecto = load([p.dataPath '/' d3_ecto_name]);
d3_endo = load([p.dataPath '/' d3_endo_name]);

d1_registeredData_ecto = d1_ecto.registeredData;
d3_registeredData_ecto = d3_ecto.registeredData;
d1_registeredData_rotated = d1_endo.registeredData;
d3_registeredData_rotated = d3_endo.registeredData;

% Dapi
intersection_registration.Dapi = d1_registeredData_ecto.DapiSegm + d3_registeredData_ecto.DapiSegm...
    + d1_registeredData_rotated.DapiSegm + d3_registeredData_rotated.DapiSegm;
figure;subplot(2,3,1);imagesc(computeMIP(d1_registeredData_ecto.DapiSegm));
title('Dapi 1'); axis tight; axis equal;
subplot(2,3,4);imagesc(computeMIP(d3_registeredData_ecto.DapiSegm));
title('Dapi 2'); axis tight; axis equal;
subplot(2,3,2);imagesc(computeMIP(d1_registeredData_rotated.DapiSegm));
title('Dapi 3'); axis tight; axis equal;
subplot(2,3,5);imagesc(computeMIP(d3_registeredData_rotated.DapiSegm));
title('Dapi 4'); axis tight; axis equal;
subplot(2,3,6);imagesc(computeMIP(intersection_registration.Dapi));
title('Intersection Dapi without threshold'); axis tight; axis equal;

inter_dapi = intersection_registration.Dapi > 1;
% GFP
intersection_registration.landmark = d1_registeredData_ecto.landmark + d3_registeredData_ecto.landmark...
    + d1_registeredData_rotated.landmark + d3_registeredData_rotated.landmark;
figure;subplot(2,3,1);imagesc(computeMIP(d1_registeredData_ecto.landmark));
title('GFP 1'); axis tight; axis equal;
subplot(2,3,4);imagesc(computeMIP(d3_registeredData_ecto.landmark));
title('GFP 2'); axis tight; axis equal;
subplot(2,3,2);imagesc(computeMIP(d1_registeredData_rotated.landmark));
title('GFP 3'); axis tight; axis equal;
subplot(2,3,5);imagesc(computeMIP(d3_registeredData_rotated.landmark));
title('GFP 4'); axis tight; axis equal;
subplot(2,3,3);imagesc(computeMIP(intersection_registration.landmark));
title('Intersection GFP without threshold'); axis tight; axis equal;


inter_landmark = intersection_registration.landmark > 1;

subplot(2,3,6); imagesc(computeMIP(inter_landmark)); title('thresholded'); axis tight; axis equal;

% Mesoderm
intersection_registration.mesoderm = d1_registeredData_ecto.mesodermSegm + d3_registeredData_ecto.mesodermSegm...
    + d1_registeredData_rotated.mesodermSegm + d3_registeredData_rotated.mesodermSegm;
figure;subplot(2,3,1);imagesc(computeMIP(d1_registeredData_ecto.mesodermSegm));
title('mesoderm 1'); axis tight; axis equal;
subplot(2,3,4);imagesc(computeMIP(d3_registeredData_ecto.mesodermSegm));
title('mesoderm 2'); axis tight; axis equal;
subplot(2,3,2);imagesc(computeMIP(d1_registeredData_rotated.mesodermSegm));
title('mesoderm 3'); axis tight; axis equal;
subplot(2,3,5);imagesc(computeMIP(d3_registeredData_rotated.mesodermSegm));
title('mesoderm 4'); axis tight; axis equal;
subplot(2,3,3);imagesc(computeMIP(intersection_registration.mesoderm));
title('Intersection mesoderm without threshold'); axis tight; axis equal;

inter_mesoderm = intersection_registration.mesoderm > 1;

subplot(2,3,6);imagesc(computeMIP(inter_mesoderm)); title('thresholded'); axis tight; axis equal;

% Ectoderm
intersection_registration.ectoderm = d1_registeredData_ecto.ectoendoSegm + d3_registeredData_ecto.ectoendoSegm;
figure;subplot(2,2,1);imagesc(computeMIP(d1_registeredData_ecto.ectoendoSegm));
title('ectoderm 1'); axis tight; axis equal;
subplot(2,2,2);imagesc(computeMIP(d3_registeredData_ecto.ectoendoSegm));
title('ectoderm 2'); axis tight; axis equal;
subplot(2,2,3);imagesc(computeMIP(intersection_registration.ectoderm));
title('Intersection ectoderm without threshold'); axis tight; axis equal;

inter_ectoderm = intersection_registration.ectoderm > 0;

subplot(2,2,4);imagesc(computeMIP(inter_ectoderm)); title('thresholded'); axis tight; axis equal;

% Endoderm
intersection_registration.endoderm = d1_registeredData_rotated.ectoendoSegm + d3_registeredData_rotated.ectoendoSegm;
figure;subplot(2,2,1);imagesc(computeMIP(d1_registeredData_rotated.ectoendoSegm));
title('endoderm 1'); axis tight; axis equal;
subplot(2,2,2);imagesc(computeMIP(d3_registeredData_rotated.ectoendoSegm));
title('endoderm 2'); axis tight; axis equal;
subplot(2,2,3);imagesc(computeMIP(intersection_registration.endoderm));
title('Intersection endoderm without threshold'); axis tight; axis equal;

inter_endoderm = intersection_registration.endoderm > 0;

subplot(2,2,4);imagesc(computeMIP(inter_endoderm)); title('thresholded'); axis tight; axis equal;

%save data
intersection_registration_threshold.Dapi = inter_dapi;
intersection_registration_threshold.landmark = inter_landmark;
intersection_registration_threshold.mesoderm = inter_mesoderm;
intersection_registration_threshold.ectoderm = inter_ectoderm;
intersection_registration_threshold.endoderm = inter_endoderm;

filename_registered_data = [p.resultsPath '\d1_d3_intersection'];
save(filename_registered_data,'intersection_registration_threshold');