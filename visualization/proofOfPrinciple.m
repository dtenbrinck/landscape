function proofOfPrinciple(results_filename, registeredData, experimentData, processedData, resolution, transformationMatrix, ellipsoid_center, samples)
%This function saves the unregistered and registered channels as TIF files

%% Registered Data

%scale colormap to [0,1]
registeredData.GFP = double(registeredData.GFP);
maxValue = max(registeredData.GFP(:));
minValue = min(registeredData.GFP(:));
registeredData.GFP = registeredData.GFP + minValue*ones(size(registeredData.GFP,1), size(registeredData.GFP,2), size(registeredData.GFP,3));
registeredData.GFP = 1/maxValue * registeredData.GFP;

%save registered GFP channel as TIF file
filename = [results_filename '_Registered_GFP.tif'];
imwrite(registeredData.GFP(:,:,1), filename)
for i = 2:size(registeredData.GFP,3)
    imwrite(registeredData.GFP(:,:,i), filename,'WriteMode','append')
end

%scale colormap to [0,1]
registeredData.mCherry = double(registeredData.mCherry);
maxValue = max(registeredData.mCherry(:));
minValue = min(registeredData.mCherry(:));
registeredData.mCherry = registeredData.mCherry + minValue*ones(size(registeredData.mCherry,1), size(registeredData.mCherry,2), size(registeredData.mCherry,3));
registeredData.mCherry = 1/maxValue * registeredData.mCherry;

%save registered GFP channel as TIF file
filename = [results_filename '_Registered_mCherry.tif'];
imwrite(registeredData.mCherry(:,:,1), filename)
for i = 2:size(registeredData.mCherry,3)
   imwrite(registeredData.mCherry(:,:,i), filename,'WriteMode','append')
end

%scale colormap to [0,1]
registeredData.Dapi = double(registeredData.Dapi);
maxValue = max(registeredData.Dapi(:));
minValue = min(registeredData.Dapi(:));
registeredData.Dapi = registeredData.Dapi + minValue*ones(size(registeredData.Dapi,1), size(registeredData.Dapi,2), size(registeredData.Dapi,3));
registeredData.Dapi = 1/maxValue * registeredData.Dapi;

%save registered GFP channel as TIF file
filename = [results_filename '_Registered_Dapi.tif'];
imwrite(registeredData.Dapi(:,:,1), filename)
for i = 2:size(registeredData.Dapi,3)
   imwrite(registeredData.Dapi(:,:,i), filename,'WriteMode','append')
end

%% Unregistered Data

% transform resolution of experiment Data
if isfield(processedData, 'GFP')
    [GFP_ProofOfPriciple, ~] = transformVoxelData(single(processedData.GFP), resolution, transformationMatrix, ellipsoid_center, samples, 'cubic');
end
if isfield(processedData, 'mCherry')
    [mCherry_ProofOfPriciple, ~] = transformVoxelData(single(processedData.mCherry), resolution, transformationMatrix, ellipsoid_center, samples, 'cubic');
end
if isfield(processedData, 'Dapi')
    [Dapi_ProofOfPriciple, ~] = transformVoxelData(single(processedData.Dapi), resolution, transformationMatrix, ellipsoid_center, samples, 'cubic');
end

%scale colormap to [0,1]
GFP_ProofOfPriciple = double(GFP_ProofOfPriciple);
maxValue = max(GFP_ProofOfPriciple(:));
minValue = min(GFP_ProofOfPriciple(:));
GFP_ProofOfPriciple = GFP_ProofOfPriciple + minValue*ones(size(GFP_ProofOfPriciple,1), size(GFP_ProofOfPriciple,2), size(GFP_ProofOfPriciple,3));
GFP_ProofOfPriciple = 1/maxValue * GFP_ProofOfPriciple;

%save unregistered GFP channel as TIF file
filename = [results_filename '_Unregistered_GFP.tif'];
imwrite(GFP_ProofOfPriciple(:,:,1), filename)
for i = 2:size(GFP_ProofOfPriciple,3)
    imwrite(GFP_ProofOfPriciple(:,:,i), filename, 'WriteMode', 'append')
end

%scale colormap to [0,1]
mCherry_ProofOfPriciple = double(mCherry_ProofOfPriciple);
maxValue = max(mCherry_ProofOfPriciple(:));
minValue = min(mCherry_ProofOfPriciple(:));
mCherry_ProofOfPriciple = mCherry_ProofOfPriciple + minValue*ones(size(mCherry_ProofOfPriciple,1), size(mCherry_ProofOfPriciple,2), size(mCherry_ProofOfPriciple,3));
mCherry_ProofOfPriciple = 1/maxValue * mCherry_ProofOfPriciple;

%save unregistered mCherry channel as TIF file
filename = [results_filename '_Unregistered_mCherry.tif'];
imwrite(mCherry_ProofOfPriciple(:,:,1), filename)
for i = 2:size(mCherry_ProofOfPriciple,3)
  imwrite(mCherry_ProofOfPriciple(:,:,i), filename,'WriteMode','append')
end

%scale colormap to [0,1]
Dapi_ProofOfPriciple = double(Dapi_ProofOfPriciple);
maxValue = max(Dapi_ProofOfPriciple(:));
minValue = min(Dapi_ProofOfPriciple(:));
Dapi_ProofOfPriciple = Dapi_ProofOfPriciple + minValue*ones(size(Dapi_ProofOfPriciple,1), size(Dapi_ProofOfPriciple,2), size(Dapi_ProofOfPriciple,3));
Dapi_ProofOfPriciple = 1/maxValue * Dapi_ProofOfPriciple;

%save unregistered Dapi channel as TIF file
filename = [results_filename '_Unregistered_Dapi.tif'];
imwrite(Dapi_ProofOfPriciple(:,:,1), filename)
for i = 2:(size(Dapi_ProofOfPriciple,3))
    imwrite(Dapi_ProofOfPriciple(:,:,i), filename,'WriteMode','append')
end
