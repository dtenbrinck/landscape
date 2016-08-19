function [ data ] = loadExperimentData( experimentSets, dataPathName, waitbarHandle )

% initialize empty struct
data = struct;

% get amount of data to be processed
numOfData = size(experimentSets,1);

% iterate over all data sets
for i=1:numOfData
  
  % try to read TIFF file and generate a substruct
  try
    % generate successive data identifier
    dataName = ['Data_',num2str(i)];
    
    % initialize substruct
    data.(dataName) = [];
    
    % ATTENTION: We assume that each TIFF file has only 2D slices of same size!
    
    % read Dapi data set from tiff file into struct
    pathFile = [dataPathName,'/',char(experimentSets{i,1})];
    TIFF = tiffread(pathFile);
    data.(dataName).Dapi ...
      = double(reshape(cell2mat({TIFF(:).('data')}),TIFF(1).('height'),TIFF(1).('width'),size(TIFF,2)));
    
    % read GFP data set from tiff file into struct
    pathFile = [dataPathName,'/',char(experimentSets{i,2})];
    TIFF = tiffread(pathFile);
    data.(dataName).GFP ...
      = double(reshape(cell2mat({TIFF(:).('data')}),TIFF(1).('height'),TIFF(1).('width'),size(TIFF,2)));
    
    % read mCherry data set from tiff file into struct
    pathFile = [dataPathName,'/',char(experimentSets{i,3})];
    TIFF = tiffread(pathFile);
    data.(dataName).mCherry ...
      = double(reshape(cell2mat({TIFF(:).('data')}),TIFF(1).('height'),TIFF(1).('width'),size(TIFF,2)));
    
    
    % TODO: Check if all data sets have same size!
    
    % save filename
    % ATTENTION: This assumes a fixed naming convention!
    data.(dataName).filename = experimentSets{i,1}{1}(1:end-11);
    
    % set resolution and size of 2D slices
    xres = TIFF.('x_resolution');
    yres = TIFF.('y_resolution');
    data.(dataName).x_resolution = xres(1);
    data.(dataName).y_resolution = yres(1);
    
  catch ME
    warning(['Some error occured while reading the TIFF file!', ...
      '\n this file will be skipped!\n The error',...
      ' message was: ',ME.message]);
    rmfield(data,dataName);
    continue;
  end
  
  if exist('waitbarHandle','var')
    % update waitbar
    waitbar(i/numOfData, waitbarHandle);
    drawnow;
  end
end


end

