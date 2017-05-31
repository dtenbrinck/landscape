function [ nameStack1, nameStack2 ] = drawRandomNames( fileNames, randomIn )

if randomIn < 1
    % Then it is percentage
    numberOfRandom = round(size(fileNames,1)*randomIn);
elseif randomIn >=1
    % Then it is a number of picks
    numberOfRandom = randomIn;
end

randIndices = sort(randsample(size(fileNames,1),numberOfRandom));
nameStack1 = fileNames(randIndices);
fileNames(randIndices) = [];
nameStack2 = fileNames;

if nargout == 2
    disp(['Divided stack of files into two random stacks of size ',num2str(numberOfRandom),' and ',num2str(size(nameStack2,1)),'.'])
elseif nargout == 1 
    disp([num2str(numberOfRandom),' files were randomly picked.'])
end
end

