function data = loadDynamicData(pathToFile)

  % read tiff data file
  tiffData = tiffread(pathToFile);
  
  % since tiffData is a struct array we determine the number of array elements
  numElements = size(tiffData,2);
  
  % determine number of slices per time frame (encoded in string)
  numSlices = str2num(tiffData(1).info( strfind(tiffData(1).info, 'slices=') + length('slices=') : ...
                                     strfind(tiffData(1).info, 'frames=') - 1));
                                   
  % determine number of frames (encoded in string)
  numFrames = str2num(tiffData(1).info( strfind(tiffData(1).info, 'frames=') + length('frames=') : ...
                                     strfind(tiffData(1).info, 'hyperstack=') - 1));
  
  % initialize container to contain data in this order: (y,x,z,t)
  data = zeros(tiffData(1).height, tiffData(1).width, numSlices, numFrames);
  
  % fill data elementwise (slices are subsequently ordered in tiffData)
  for element = 1:numElements
    data(:,:,mod(element-1,numSlices)+1,ceil(element/numSlices)) = tiffData(element).data;
  end

end