function fileNames = getSTKfilenames( pathName )

% get all stk files in selected folder
stkFiles = strcat(pathName,'/*.stk');
listOfFiles = dir(stkFiles);

% get number of stkFiles
numberOfFiles = numel(listOfFiles);

% put all STK filenames in a list
fileNames = cell(numberOfFiles,1);
for i=1:numberOfFiles
    fileNames{i} = listOfFiles(i).name;
end

end

