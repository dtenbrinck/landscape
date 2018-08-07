function fileNames = getMATtracks_corrected( pathName )

% get all mat files in selected folder
% only include the specific corrected dynamic data mat files
files = strcat(pathName,'/*_corrected_k6.mat');
listOfFiles = dir(files);

% get number of files
numberOfFiles = numel(listOfFiles);

% put all filenames in a list
fileNames = cell(numberOfFiles,1);
for i=1:numberOfFiles
    fileNames{i} = listOfFiles(i).name;
end

end

