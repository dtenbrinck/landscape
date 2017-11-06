%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('evaluate', root_dir);


%% GET FILES TO PROCESS

% check results directory
checkDirectory(p.resultsPath);

p.resultsPath = strcat(p.resultsPath, '/accepted');

% get filenames of STK files in selected folder
fileNames = getMATfilenames(p.resultsPath);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];
% get number of experiments
numberOfResults = size(fileNames,1);

% check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(p.resultsPath);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for processing.']);
end

% initialize container for statistics
XY = zeros(1, numberOfResults);
XZ = zeros(1, numberOfResults);

%% MAIN EVALUATION LOOP
h = figure('units','normalized','outerposition',[0 0 1 1]); 
result = 0;
while result < numberOfResults
    
    % increase counter
    result = result + 1;
    
    % load result data
    load([p.resultsPath,'/',fileNames{result,1}])
    
    % get radii of fitted ellipsoid
    radii = gatheredData.processed.ellipsoid.radii;
    
    % compute ratio between X/Y and X/Z axis
    XY(result) = radii(2) / radii(1);
    XZ(result) = radii(3) / radii(1);    
    
end

% compute mean and variance
XY_mean = mean(XY(:));
XZ_mean = mean(XZ(:));

XY_var = var(XY(:));
XZ_var = var(XZ(:));


%% USER OUTPUT
disp('All results in folder processed!');

disp('Ratio between ellipsoid X-Y axis:');
disp(['mean: ' num2str(XY_mean)]);
disp(['variance: ' num2str(XY_var)]);

disp('Ratio between ellipsoid X-Z axis:');
disp(['mean: ' num2str(XZ_mean)]);
disp(['variance: ' num2str(XZ_var)]);

close all;