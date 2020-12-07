function fileNames = getSTKfilenames( pathName )
%% Output:
%  filenames:      nx1 cell containing the filenames 

%% Code

% get all stk files in selected folder
files = strcat(pathName,'/*.stk');
listOfFiles = dir(files);

% get number of stkFiles
numberOfFiles = numel(listOfFiles);

% put all STK filenames in a list
fileNames = cell(numberOfFiles,1);
for i=1:numberOfFiles
    fileNames{i} = listOfFiles(i).name;
end

end

