function fileNames = getTIFfilenames( pathName )

% get all tif files in selected folder
tifFiles = strcat(pathName,'/*.tif');
listOfFiles = dir(tifFiles);

% get number of stkFiles
numberOfFiles = numel(listOfFiles);

% put all TIF filenames in a list
fileNames = cell(numberOfFiles,1);
for i=1:numberOfFiles
    fileNames{i} = listOfFiles(i).name;
end

end

