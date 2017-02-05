% clean the working environment
clc; clear; close all;

% path definition to the given data
data_path = '/share/imaging/data/Data Raz Lab/SargonYigit/2D Image Registration/';

% path definition of the converted data
converted_data_path = [pwd() '/data/'];

% create a new directory for converted data if it not yet exists
if ~exist(converted_data_path, 'dir')
    mkdir(converted_data_path);
end

% get list of all subfolders
subfolders = genpath(data_path);

%%% Parse the resulting string into a cell array.

% initialize remain as current string
remain = subfolders;

% initialize empty cell array to hold subfolders
listOfFolderNames = {};

% sequentially loop until every substring is deleted
while ~isempty(remain)
    
    % split at the : character
    [singleSubFolder, remain] = strtok(remain, ':');
    
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

% loop over all detected subfolders
for i=1:numberOfFolders
    
    % get current subfolder
    current_subfolder_path = listOfFolderNames{i};
    
    % print current subfolder
    disp(['%%% Processing folder: ' current_subfolder_path]);
    
    % initialize remain as whole path string
    remain = current_subfolder_path;
    
    % iterate over path string until subfolder name is determined
    while ~isempty(remain)
        
        % split at the / character
        [folder, remain] = strtok(remain, '/');
        
        % check that parent directory is not included
        %if ~strcmp(r, data_path)
        %    % add subfolder path to array
        %    listOfFolderNames = [listOfFolderNames singleSubFolder];
        %end
        
    end
    
    % generate new path for converted files in subfolder
    converted_subfolder_path = [converted_data_path folder];
    
    % create a new subdirectory for matlab files if it not yet exists
    if ~exist(converted_subfolder_path, 'dir')
        mkdir(converted_subfolder_path);
    end
    
    % get list of all present MetaMorph (*.stk) files
    stkFiles = dir([current_subfolder_path '/*.stk']);
    
    % get number of MetaMorph (*.stk) files
    numberOfFiles = length(stkFiles);
    
    % print number of MetaMorph (*.stk) files
    disp(['% Found ' num2str(numberOfFiles) ' MetaMorph (*.stk) files!']);
    
    % print new line to show current processing status
    disp(['% Processing file: (0/' num2str(numberOfFiles) ')']);
    
    % initialize experiment number to -1
    currentExperimentNumber = -1;
    
    % iterate over all files in subfolder
    for j=1:numberOfFiles
        
        % get current file path
        current_file_path = [current_subfolder_path '/' stkFiles(j).name];
        
        % print currently processed file number
        dispCounter(j,numberOfFiles);
        
        % get file number (we assume this is the first part of the file
        % name separated by the character _ )
        [currentFileNumber, remain] = strtok(stkFiles(j).name, '_');
        
        % some of the files have a double __ so we separate another time
	if remain(1) == '_'
          remain = strtok(remain, '_');
	end
        
        % get dye of experiment (we assume this is the second part of the
        % file name separated by the characters _ and .)
        currentDye = strtok(remain, '.');
        
        % cut away the character _ at the beginning
        currentDye = currentDye(1:end);
        
        % check if related data is already be processed
        if ~strcmp(currentFileNumber, currentExperimentNumber)
   
            % save data belonging to last experiment as matlab file in
            % the current subfolder
            if exist('data','var')
                save([converted_subfolder_path '/' num2str(currentExperimentNumber) '.mat'], 'data');
                clear data;
            end
            
            % set current experiment number to the current file number
            currentExperimentNumber = currentFileNumber;
            
        end
        
        % read the tiff stack into the data variable
        tmpData = tiffread(current_file_path);
        
        % get dimensions of a single slice (we assume all slices in stack
        % have the same dimension)
        [ny, nx] = size(tmpData(1).data);
        
        % get number of slices
        nz = length(tmpData);
        
        % initialize empty 3D matrix
        data.(currentDye) = zeros(ny, nx, nz);
        
        % copy data
        for k=1:nz
            data.(currentDye)(:,:,k) = tmpData(k).data;
        end

	% add additional fields for the x-/y-resolution
	data.x_resolution = tmpData(1).x_resolution(1);	
	data.y_resolution = tmpData(1).y_resolution(1);	
        
    end
    
    % save data belonging to last experiment as matlab file in
    % the current subfolder
    if exist('data','var')
        save([converted_subfolder_path '/' num2str(currentExperimentNumber) '.mat'], 'data');
        clear data;
    end
    
    fprintf('\r');
end

disp('Done');
