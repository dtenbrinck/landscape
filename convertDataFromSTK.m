% clean the working environment
clc; clear workspace; close all;

% hard path definition to the given data
data_path = '/share/imaging/data/Data Raz Lab/SargonYigit/2D Image Registration/';

% get list of all subfolders
subfolders = genpath(data_path);

%%% Parse the resulting string into a cell array.

% initialize remain as current string
remain = subfolders;

% initialize empty cell array to hold subfolders
listOfFolderNames = {};

% sequentially loop until every substring is deleted
while true
    
    % split at the : character
	[singleSubFolder, remain] = strtok(remain, ':');
	
    % terminate when string is empty
    if isempty(singleSubFolder)
		break;
    end
    
    % check that parent directory is not included
    if ~strcmp(singleSubFolder, data_path)
        % add subfolder path to array 
        listOfFolderNames = [listOfFolderNames singleSubFolder];
    end
end

% print number of subfolders
numberOfFolders = length(listOfFolderNames);
disp(['Number of detected folders: ' num2str(numberOfFolders)]);

%%% Process each subfolder

% change diretory to data directory
cd(data_path);

% loop over all detected subfolders
for i=1:numberOfFolders
    
    % print current folder
    disp(['%%% Processing folder: ' listOfFolderNames{i}]);
    
    % change to subfolder
    cd(listOfFolderNames{i});
    
    % create a new subdirectory for matlab files if it not yet exists
    if ~exist('matlab', 'dir')
        mkdir('matlab');
    end
    
    % get list of all present MetaMorph (*.stk) files
    numberOfFiles = 
    
    % iterate over all files in subfolder
    for j=1:numberOfFiles
      
      % get file number (we assume this is the first part of the file name)
      currentFileNumber = 
      
      % check if related data is already be processed
      if currentFileNumber == currentExperimentNumber
        
      else
        
      end
      
      % save file as matlab file in respective folder
      
    end
    
    % change directory back to parent directory
    cd ..;
end

