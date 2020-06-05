function visualizeResults_evaluation(f,gatheredData)
%VISUALIZERESULTS Summary of this function goes here
%   Detailed explanation goes here

clf(f)

text(0.05,0.05,'TEST', 'Units', 'normalized', 'FontSize', 15, 'FontName', 'Arial');
% visualize original data
subplot(3,3,1); imagesc((gatheredData.experiment.DapiMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
    text(0.5, 1.1,'Nuclei', 'Units', 'normalized', 'FontSize', 15, 'FontName', 'Arial', 'HorizontalAlignment', 'center');
    text(-0.2,0.5,'Input Data', 'rotation', 90, 'Units', 'normalized', 'FontSize', 15, 'FontName', 'Arial', 'HorizontalAlignment', 'center');
subplot(3,3,2); imagesc((gatheredData.experiment.GFPMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
    text(0.5, 1.1,'Landmark', 'Units', 'normalized', 'FontSize', 15, 'FontName', 'Arial', 'HorizontalAlignment', 'center');
subplot(3,3,3); imagesc((gatheredData.experiment.mCherryMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
    text(0.5, 1.1,'Cells/Tissue of Interest', 'Units', 'normalized', 'FontSize', 15, 'FontName', 'Arial', 'HorizontalAlignment', 'center');

% visualize segmentation results in preprocessed data
subplot(3,3,4); imagesc((gatheredData.processed.DapiMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
    position = (-0.7*size(gatheredData.experiment.DapiMIP, 2)*size(gatheredData.processed.DapiMIP,1))/(size(gatheredData.experiment.DapiMIP,1)*size(gatheredData.processed.DapiMIP,2))+0.5;
    text(position,0.5,'Segmented Data', 'Units', 'normalized', 'rotation', 90, 'FontSize', 15, 'FontName', 'Arial', 'HorizontalAlignment', 'center');
if isfield(gatheredData.processed, 'nucleiMIP') % check for backward compatibilty
    if min(gatheredData.processed.nucleiMIP(:)) ~= max(gatheredData.processed.nucleiMIP(:))
        hold on; contour((gatheredData.processed.nucleiMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    end
end
subplot(3,3,5); imagesc((gatheredData.processed.GFPMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
hold on; contour((gatheredData.processed.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off; 
subplot(3,3,6); imagesc((gatheredData.processed.mCherryMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
hold on; contour((gatheredData.processed.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

% visualize segmentation results in registered data 
subplot(3,3,7); imagesc((gatheredData.registered.DapiMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
    position = (-0.7*size(gatheredData.experiment.DapiMIP, 2)*size(gatheredData.registered.DapiMIP,1))/(size(gatheredData.experiment.DapiMIP,1)*size(gatheredData.registered.DapiMIP,2))+0.5;
    text(position,0.5,'Registered Data', 'rotation', 90, 'Units', 'normalized', 'FontSize', 15, 'FontName', 'Arial', 'HorizontalAlignment', 'center');
if isfield(gatheredData.registered, 'nucleiMIP') % check for backward compatibilty
    if min(gatheredData.registered.nucleiMIP(:)) ~= max(gatheredData.registered.nucleiMIP(:))
        hold on; contour((gatheredData.registered.nucleiMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    end
end
subplot(3,3,8); imagesc((gatheredData.registered.GFPMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
if min(gatheredData.registered.landmarkMIP(:)) ~= max(gatheredData.registered.landmarkMIP(:))
hold on; contour((gatheredData.registered.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
end
subplot(3,3,9); imagesc((gatheredData.registered.mCherryMIP)); axis image; set(gca, 'xtick',[],'ytick',[]);
if min(gatheredData.registered.cellsMIP(:)) ~= max(gatheredData.registered.cellsMIP(:))
hold on; contour((gatheredData.registered.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
end

suptitle(['Results for dataset: ' strrep(gatheredData.filename,'_','\_')]);

drawnow;
end