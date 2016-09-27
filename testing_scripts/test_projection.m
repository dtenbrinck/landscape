% clean up
clc; clear; close all;

% add needed subfolders
addpath(genpath('../'));

% set resolution of data
scale = 0.5;
resolution = [1.29 1.29 20];
resolution(1:2) = resolution(1:2) / scale;

% check if data has been loaded and segmented already
if ~exist('segmented_data.mat','file')
  
  % check if data has been loaded already
  if ~exist('all_data.mat','file')
    
    % define data path
    dataPathName = '../data/bad_data';
    
    % get filenames of STK files in selected folder
    fileNames = getSTKfilenames(dataPathName);
    
    % extract only valid experiments with three data sets
    experimentSets = checkExperimentChannels(fileNames);
    
    % load data for each experiment
    all_data = loadExperimentData(experimentSets, dataPathName);
    
    % save data
    save('all_data.mat', 'all_data');
    
  else
    
    % load data from mat file
    file_content = load('all_data.mat');
    all_data = file_content.all_data;
    
  end
  
  % Compute the segmentaion of landmark and cells
  fprintf('Starting segmentation ...\n');
  output = LACSfun(all_data.Data_1,resolution,scale);
  fprintf('Segmentation Done!\n');
  
  % save data
  save('segmented_data.mat', 'output');
  
else
  
  % load data from mat file
  file_content = load('segmented_data.mat');
  output = file_content.output;
  
end

samples = 128;

% strange because double!
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Sample the unit cube
[Xc, Yc, Zc] = meshgrid(linspace(-1,1,samples), linspace(-1,1,samples), linspace(-1,1,samples));

% Compute the transformed sphere and cube
output.tSphere = struct;
output.tCube = struct;

% Projection: %
fprintf('Starting projection onto the unit sphere and unit cube...');
% Sample original space
mind = [0 0 0]; maxd = size(output.landmark) .* resolution;
%Create meshgrid with same resolution as data
[ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(output.landmark,2) ),...
  linspace( mind(1), maxd(1), size(output.landmark,1) ),...
  linspace( mind(3), maxd(3), size(output.landmark,3) ) );

% Transform unit sphere...
scale_matrix = diag(1./output.ellipsoid.radii);
rotation_matrix = output.ellipsoid.axes';

output.GFPOnSphere = zeros(size(alpha));

for boundary = 0.80:0.01:1.2

  scale_matrix = diag(1./output.ellipsoid.radii) * boundary;
  
[output.tSphere.Xs_t,output.tSphere.Ys_t,output.tSphere.Zs_t,output.ellipsoid.axes] ...
  = transformUnitSphere3D(Xs,Ys,Zs,scale_matrix,rotation_matrix,output.ellipsoid.center);

% Project segmented landmark onto unit sphere...
tmp ...
  = interp3(X, Y, Z, output.landmark, output.tSphere.Xs_t, output.tSphere.Ys_t, output.tSphere.Zs_t,'nearest');
figure; imagesc(tmp); pause;

output.GFPOnSphere = max(output.GFPOnSphere, tmp);
end

% ... and cube
[output.tCube.Xc_t,output.tCube.Yc_t,output.tCube.Zc_t] ...
  = transformUnitCube3D(Xc,Yc,Zc,scale_matrix,rotation_matrix,output.ellipsoid.center);

% ... and cells into unit cube
CellsInSphere ...
  = interp3(X, Y, Z, output.cells, output.tCube.Xc_t, output.tCube.Yc_t, output.tCube.Zc_t,'nearest');
CellsInSphere(isnan(CellsInSphere)) = 0;
output.CellsInSphere = CellsInSphere;
fprintf('Done!\n');

size_markers = ones(numel(Xs),1);
size_markers(output.GFPOnSphere == 1) = 100;
size_markers(output.GFPOnSphere == 0) = 5;

figure; scatter3(Xs(:),Ys(:),Zs(:), size_markers, -1*output.GFPOnSphere(:)); colormap gray;