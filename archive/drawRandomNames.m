function [ fileNames ] = drawRandomNames( fileNames, numberOfRandom )

randIndices = sort(randsample(size(fileNames,1),numberOfRandom));
fileNames = fileNames(randIndices);

end

