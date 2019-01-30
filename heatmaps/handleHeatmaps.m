function [  ] = handleHeatmaps( accumulator,shells,numOfAllCells,numberOfResults, p, option )
% This function will handle the heatmaps. It will compute and show
% different heatmaps depending on the given options in 'option'.

%% MAIN CODE

% -- if heatmaps should be computed -- %
if option.heatmaps.process == 1
    fprintf('Computing heatmaps...\n');
    
    % -- Convolve over the points -- %
    convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);
    
    % -- Compute mercator projections -- %
    mercatorProjections = computeMercatorProjections(shells, option.shellHeatmapResolution); 
    
    % -- Compute heatmap heatmaps -- %
    HMS = generateHeatmap(convAcc,option.heatmaps.types);
    
    % -- fix paths in case we are generating for special channel --%
    heatmapsPath = [p.resultsPath ,'/heatmaps'];
    if isfield(p,'handledChannel')
        heatmapsPath= [heatmapsPath, '/', p.handledChannel];
    end
    if ~exist([heatmapsPath,'/'],'dir')
        mkdir(heatmapsPath);
    end
    % Save heatmap structure HMS
    if option.heatmaps.saveHMmat == 1
        mat_name = [heatmapsPath,'/','Heatmap_Structure.mat'];
        save(mat_name,'HMS');
    end
    
    % Save accumulator
    if option.heatmaps.saveAccumulator == 1
        mat_name = [heatmapsPath,'/','Accumulator.mat'];
        save(mat_name,'accumulator');
    end
    
    % -- Create the figures -- %
    vis = 'on';
    if option.heatmaps.disp == 0
        vis = 'off';
    end
    
    for i=1:size(option.heatmaps.types,2)
        currentType = option.heatmaps.types{i};
        figs = [figure('Visible','off'),figure('Visible','off'),...
            figure('Visible','off'),figure('Visible','off')];
        if strcmp(option.heatmaps.scaled,'true')||strcmp(option.heatmaps.scaled,'both')
            [f,pca] = creatStdFigure_scaled(numberOfResults,numOfAllCells,HMS,currentType);      
            figs(i+(2*(i-1))) = copyobj(f,0);
            %set(findobj(figs(i+(2*(i-1))).Children,'Tag','sp3'),'position',pca); % TODO: IS THIS REALLY NEEDED?
            set(figs(i+(2*(i-1))),'Visible',vis);
            
            if option.heatmaps.save == 1
                for j=1:size(option.heatmaps.saveas,2)
                    fig_filename = [heatmapsPath,'/',currentType,'_Heatmaps'];
                    saveas(f,fig_filename,option.heatmaps.saveas{j});
                end
            end
        end
        if strcmp(option.heatmaps.scaled,'false')||strcmp(option.heatmaps.scaled,'both')
            % Create figure
            f = creatStdFigure_unscaled(numberOfResults,numOfAllCells,HMS,currentType); 
            figs(i+1+(2*(i-1))) = copyobj(f,0);
            set(figs(i+1+(2*(i-1))),'Visible',vis);
            
            if option.heatmaps.save == 1
                for j=1:size(option.heatmaps.saveas,2)
                    fig_filename = [heatmapsPath,'/',currentType,'_Heatmaps(unscaled)'];
                    saveas(f,fig_filename,option.heatmaps.saveas{j});
                end
            end
        end
    end

end

% -- if slider should be shown --  %

if option.slider == 1
    disp('Slider');
    gui_slider(p,option,accumulator,convAcc,numOfAllCells,numberOfResults);
end

% -- if cropper should be shown --  %

if option.cropper == 1
    disp('Cropper');
    gui_cropRegion(accumulator,HMS.MIP.Top,200);
end


% -- Determine maximum value in all heatmaps for easier comparison -- %
maxi = -1;
for j=1:size(mercatorProjections,3)
    projection = mercatorProjections(:,:,j);
    tmp_max = max(projection(:));
    if maxi < tmp_max
        maxi = tmp_max;
    end
end

% -- Save shell heatmaps -- %
f = figure;
for j=1:size(mercatorProjections,3)
    imagesc(mercatorProjections(:,:,j),[0 maxi]);
    saveas(f,[heatmapsPath '/shellHeatmap_' num2str(j) '.png'],'png');
end

end
