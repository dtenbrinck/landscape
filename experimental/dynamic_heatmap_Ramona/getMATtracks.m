function fileNames = getMATtracks( pathName )

% get all stk files in selected folder
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

