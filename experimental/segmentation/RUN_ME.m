%% INITIALIZATION
clear; clc; close all;

% change directory to root directory
currentDir = pwd;
cd ../../;

% add path for parameter setup
addpath('./parameter_setup/');
addpath(genpath('./experimental/'));

% load necessary variables
p = initializeScript('process');

% manual set resolution parameter
manRes = [0,0,0];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARAMETER SETTINGS

%%% segmentation parameters
options.method = 'Chan-Vese-L1+Sobel'; % Chan-Vese-L1 % Chan-Vese-L2 % Sobel % Chan-Vese-L1+Sobel % Malon % Chan-Vese-L1-inc % Chan-Vese-L2-inc
options.lambda = 2;

%%% output SAVE options
options.show_scale_images = false;
options.save_rois = false;
options.save_dp_result = false;
options.save_segmentation_result = false;
options.file_format = '.png'; % '.png' % '.jpg' % '.eps'

%%% output SHOW options
options.show_segmentation_result = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% PREPARE RESULTS DIRECTORY
checkDirectory(p.resultsPath);

%% LOAD DATA

% get filenames of STK files in selected folder
fileNames = getSTKfilenames(p.dataPath);

% extract only valid experiments with three data sets
allValidExperiments = checkExperimentChannels(fileNames);

% get number of experiments
numberOfExperiments = size(allValidExperiments,1);

% adjust resolution according to scale parameter
p.resolution(1:2) = p.resolution(1:2) / p.scale;

%% MAIN LOOP

fprintf(['Processing dataset: (0,' num2str(numberOfExperiments) ')']);

% process all existing data sequentially
for experiment=1:numberOfExperiments
  
  % show remotecurrent experiment number
  dispCounter(experiment, numberOfExperiments);
  
  % get data of current experiment
  if p.debug_level >= 1; disp('Loading data...'); end
  experimentData = loadExperimentData(allValidExperiments(experiment,:), p.dataPath,manRes);
  if isfield(experimentData,'manualxRes')
    manRes(1) = 1;
    manRes(2) = experimentData.manualxRes;
    manRes(3) = experimentData.manualyRes;
    experimentData = rmfield(experimentData,'manualyRes');
    experimentData = rmfield(experimentData,'manualxRes');
  end
  experimentData = experimentData.Data_1;
  
  % preprocess and rescale data
  if p.debug_level >= 1; disp('Preprocessing data...'); end
  processedData = preprocessData(experimentData, p);
  
  %% SEGMENTATION OF GFP CHANNEL
  
  % segment data
  %if p.debug_level >= 1; disp('Segmenting GFP channel...'); end
  %processedData.landmark = segmentGFP(processedData.GFP, p.GFPseg, p.resolution);
  
  
  %% SEGMENTATION OF MCHERRY CHANNEL (CELLS)
  if p.debug_level >= 1; disp('Segmenting mCherry channel...'); end
  [processedData.cells, processedData.cellCoordinates] = segmentCells(processedData.mCherry, p.mCherryseg, p.resolution);
  
  
  im = computeMIP(processedData.mCherry);
  im2 = computeMIP(processedData.cells);
  h = figure(1); set(h,'Units','normalized','Position',[0.1 0.1 0.9 0.9]); imagesc(im,[0, max(im(:))/2]); colormap gray;
  text(size(im,2) / 2, -30, 'Select center point of cell!', 'HorizontalAlignment','center', 'BackgroundColor',[.7 .9 .7]);
  
  while true
    
    figure(1); drawSegmentation(im, im2);
    
    [xCenter yCenter] = ginput(1);
    text(size(im,2) / 2, -30, 'Select point outside of cell (~ double distance to membrane)!', 'HorizontalAlignment','center', 'BackgroundColor',[.7 .9 .7]);
    [xOutside yOutside] = ginput(1);
    %close(h);
    pause(0.1);
    
    
    %%% compute bounding box
    distance = norm([xCenter yCenter] - [xOutside yOutside],2);
    %distance = 30;
    yMin = round(yCenter - distance);
    yMax = round(yCenter + distance);
    xMin = round(xCenter - distance);
    xMax = round(xCenter + distance);
    
    if yMin >= 0 && yMax < size(im,1) && xMin >= 0 && xMax < size(im,2)
      
      %%% extract roi
      roi = im(yMin:yMax, xMin:xMax);
      %load('roi_cell2.mat');
      
      options.numberAngles = 360;
      options.numberRadii = max(size(roi));
      
      profile on
      %%%%%%%%%% segment image
      segmentation = segmentCell(roi,options, fileNames{experiment});
      profile viewer
      profile off
      
      im2(yMin:yMax,xMin:xMax) = im2(yMin:yMax,xMin:xMax) | segmentation;
      
    else
      disp('Error: ROI to small for specified points!');
    end
    
    figure(1); drawSegmentation(im, im2);
    pause(0.1);
    
  end
  
end

cd(currentDir);

