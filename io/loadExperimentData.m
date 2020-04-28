function [ data ] = loadExperimentData( experimentSets, dataPathName )

% initialize empty struct
data = struct;
  
% try to read TIFF file and generate a substruct
try

% ATTENTION: We assume that each TIFF file has only 2D slices of same size!

% read Dapi data set from tiff file into struct
pathFile = [dataPathName,'/',char(experimentSets{1,1})];
TIFF = tiffread(pathFile);
data.Dapi ...
  = single(reshape(cell2mat({TIFF(:).('data')}),TIFF(1).('height'),TIFF(1).('width'),size(TIFF,2)));

% read GFP data set from tiff file into struct
pathFile = [dataPathName,'/',char(experimentSets{1,2})];
TIFF = tiffread(pathFile);
data.GFP ...
  = single(reshape(cell2mat({TIFF(:).('data')}),TIFF(1).('height'),TIFF(1).('width'),size(TIFF,2)));

% read mCherry data set from tiff file into struct
if size(experimentSets,2) > 2 %% TODO sasser TEST THIS!!
    pathFile = [dataPathName,'/',char(experimentSets{1,3})];
    TIFF = tiffread(pathFile);
    data.mCherry ...
      = single(reshape(cell2mat({TIFF(:).('data')}),TIFF(1).('height'),TIFF(1).('width'),size(TIFF,2)));
end

% TODO: Check if all data sets have same size!

% save filename
% ATTENTION: This assumes a fixed naming convention!
index = strfind(experimentSets{1,1}{1},'_');
data.filename = experimentSets{1,1}{1}(1:index-1);

catch ME
warning(['Some error occured while reading the TIFF file!', ...
  '\n this file will be skipped!\n The error',...
  ' message was: ',ME.message]);
end

if exist('waitbarHandle','var')
% update waitbar
waitbar(1/numOfData, waitbarHandle);
drawnow;
end

end

