function visualizeResults(experimentData, processedData, registeredData)
%VISUALIZERESULTS Summary of this function goes here
%   Detailed explanation goes here

% open a fullscreen window
figure('units','normalized','outerposition',[0 0 1 1]); 

% visualize original data
subplot(3,3,1); imagesc(computeMIP(experimentData.Dapi)); title('Original DAPI channel');
subplot(3,3,2); imagesc(computeMIP(experimentData.GFP)); title('Original GFP channel');
subplot(3,3,3); imagesc(computeMIP(experimentData.mCherry)); title('Original mCherry channel');

% visualize segmentation results in preprocessed data
subplot(3,3,4); imagesc(computeMIP(processedData.Dapi)); title('Processed DAPI channel');
subplot(3,3,5); imagesc(computeMIP(processedData.GFP)); title('Segmentation in processed GFP channel');
hold on; contour(computeMIP(processedData.landmark), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
subplot(3,3,6); imagesc(computeMIP(processedData.mCherry)); title('Segmentation in processed mCherry channel');
hold on; contour(computeMIP(processedData.cells), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

% visualize segmentation results in registered data
subplot(3,3,7); imagesc(computeMIP(registeredData.Dapi)); title('Registered DAPI channel');
subplot(3,3,8); imagesc(computeMIP(registeredData.GFP)); title('Segmentation in registered GFP channel');
hold on; contour(computeMIP(registeredData.landmark), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
subplot(3,3,9); imagesc(computeMIP(registeredData.mCherry)); title('Segmentation in registered mCherry channel');
hold on; contour(computeMIP(registeredData.cells), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

suptitle(['Results for file: ' strrep(experimentData.filename,'_','\_')]);

drawnow;
pause(0.1);
end

