function tiffsave( data )
%TIFFSAVE Summary of this function goes here
%   Detailed explanation goes here

slices = size(data,3);

outputFileName = 'results/tiffs/img_stack.tif';
for K=1:slices
   imwrite(data(:, :, K), outputFileName, 'WriteMode', 'append',  'Compression','none');
end


end

