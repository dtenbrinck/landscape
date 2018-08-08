function data = loadStaticTIF(pathToFile)

  % read tiff data file
  tiffData = tiffread(pathToFile);
  
  % since tiffData is a struct array we determine the number of array elements
  numSlices = size(tiffData,2);
 
  % initialize container to contain data in this order: (y,x,z,t)
  data = zeros(tiffData(1).height, tiffData(1).width, numSlices);
  
  % fill data elementwise (slices are subsequently ordered in tiffData)
  for element = 1:numSlices
    data(:,:,element) = tiffData(element).data;
  end

end