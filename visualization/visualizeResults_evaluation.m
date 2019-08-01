function visualizeResults_evaluation(f,gatheredData)
%VISUALIZERESULTS Summary of this function goes here
%   Detailed explanation goes here

clf(f)
% visualize original data
subplot(3,3,1); imagesc((gatheredData.experiment.DapiMIP)); title('Original DAPI channel'); axis image;
subplot(3,3,2); imagesc((gatheredData.experiment.GFPMIP)); title('Original GFP channel'); axis image;
subplot(3,3,3); imagesc((gatheredData.experiment.mCherryMIP)); title('Original mCherry channel'); axis image;

% visualize segmentation results in preprocessed data
subplot(3,3,4); imagesc((gatheredData.processed.DapiMIP)); title('Segmentation in processed DAPI channel'); axis image;
if isfield(gatheredData.processed, 'nucleiMIP') % check for backward compatibilty
    if min(gatheredData.processed.nucleiMIP(:)) ~= max(gatheredData.processed.nucleiMIP(:))
        hold on; contour((gatheredData.processed.nucleiMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    end
end
subplot(3,3,5); imagesc((gatheredData.processed.GFPMIP)); title('Segmentation in processed GFP channel'); axis image;
hold on; contour((gatheredData.processed.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
subplot(3,3,6); imagesc((gatheredData.processed.mCherryMIP)); title('Segmentation in processed mCherry channel'); axis image;
hold on; contour((gatheredData.processed.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

% visualize segmentation results in registered data 
subplot(3,3,7); imagesc((gatheredData.registered.DapiMIP)); title('Registered DAPI channel'); axis image;
if isfield(gatheredData.registered, 'nucleiMIP') % check for backward compatibilty
    if min(gatheredData.registered.nucleiMIP(:)) ~= max(gatheredData.registered.nucleiMIP(:))
        hold on; contour((gatheredData.registered.nucleiMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    end
end
subplot(3,3,8); imagesc((gatheredData.registered.GFPMIP)); title('Segmentation in registered GFP channel'); axis image;
if min(gatheredData.registered.landmarkMIP(:)) ~= max(gatheredData.registered.landmarkMIP(:))
hold on; contour((gatheredData.registered.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
end
subplot(3,3,9); imagesc((gatheredData.registered.mCherryMIP)); title('Segmentation in registered mCherry channel'); axis image;
if min(gatheredData.registered.cellsMIP(:)) ~= max(gatheredData.registered.cellsMIP(:))
hold on; contour((gatheredData.registered.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
end

suptitle(['Results for file: ' strrep(gatheredData.filename,'_','\_')]);

drawnow;
end