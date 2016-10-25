function visualizeResults_new(gatheredData)
%VISUALIZERESULTS Summary of this function goes here
%   Detailed explanation goes here

% open a fullscreen window
figure('units','normalized','outerposition',[0 0 1 1]); 

% visualize original data
subplot(3,3,1); imagesc((gatheredData.experiment.DapiMIP)); title('Original DAPI channel');
subplot(3,3,2); imagesc((gatheredData.experiment.GFPMIP)); title('Original GFP channel');
subplot(3,3,3); imagesc((gatheredData.experiment.mCherryMIP)); title('Original mCherry channel');

% visualize segmentation results in preprocessed data
subplot(3,3,4); imagesc((gatheredData.processed.DapiMIP)); title('Processed DAPI channel');
subplot(3,3,5); imagesc((gatheredData.processed.GFPMIP)); title('Segmentation in processed GFP channel');
hold on; contour((gatheredData.processed.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
subplot(3,3,6); imagesc((gatheredData.processed.mCherryMIP)); title('Segmentation in processed mCherry channel');
hold on; contour((gatheredData.processed.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

% visualize segmentation results in registered data
subplot(3,3,7); imagesc((gatheredData.registered.DapiMIP)); title('Registered DAPI channel');
subplot(3,3,8); imagesc((gatheredData.registered.GFPMIP)); title('Segmentation in registered GFP channel');
hold on; contour((gatheredData.registered.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
subplot(3,3,9); imagesc((gatheredData.registered.mCherryMIP)); title('Segmentation in registered mCherry channel');
hold on; contour((gatheredData.registered.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

suptitle(['Results for file: ' strrep(gatheredData.filename,'_','\_')]);

drawnow;
pause(0.1);
end

