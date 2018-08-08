function visualizeResults_evaluation_dynamic(f,gatheredData)
%VISUALIZERESULTS Summary of this function goes here
%   Detailed explanation goes here

clf(f)
% visualize original data
subplot(3,2,1); imagesc((gatheredData.experiment.DapiMIP)); title('Original DAPI channel');
subplot(3,2,2); imagesc((gatheredData.experiment.GFPMIP)); title('Original GFP channel');

% visualize segmentation results in preprocessed data
subplot(3,2,3); imagesc((gatheredData.processed.DapiMIP)); title('Segmentation in processed DAPI channel');
if isfield(gatheredData.processed, 'nucleiMIP') % check for backward compatibilty
    hold on; contour((gatheredData.processed.nucleiMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
end
subplot(3,2,4); imagesc((gatheredData.processed.GFPMIP)); title('Segmentation in processed GFP channel');
hold on; contour((gatheredData.processed.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

% visualize segmentation results in registered data 
subplot(3,2,5); imagesc((gatheredData.registered.DapiMIP)); title('Registered DAPI channel'); axis image;
if isfield(gatheredData.registered, 'nucleiMIP') % check for backward compatibilty
    hold on; contour((gatheredData.registered.nucleiMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
end
subplot(3,2,6); imagesc((gatheredData.registered.GFPMIP)); title('Segmentation in registered GFP channel'); axis image;
hold on; contour((gatheredData.registered.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

suptitle(['Results for file: ' strrep(gatheredData.filename,'_','\_')]);

drawnow;
end

