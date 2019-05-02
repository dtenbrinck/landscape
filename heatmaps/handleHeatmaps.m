function [  ] = handleHeatmaps( accumulators,shells,numberOfResults, p )
% This function will handle the heatmaps. It will compute and show
% different heatmaps depending on the given options in 'option'.

%% MAIN CODE

option = p.option;

channels = ["GFP", "DAPI", "mCherry"];
mercatorProjections = cell(1,3);

if option.heatmaps.saveAccumulator == 1
    save([p.resultsPath '/AllAccumulators.mat'],'accumulators','shells');
end
    

% -- if heatmaps should be computed -- %
fprintf('Computing heatmaps...\n');

% iterate over all three channels
for j=1:3
    
    % extract information for current channel
    switch j
        case 1
            currentAccumulator = accumulators.GFP;
            currentShell = shells.GFP;
        case 2
            currentAccumulator = accumulators.DAPI;
            currentShell = shells.DAPI;
        case 3
            currentAccumulator = accumulators.mCherry;
            currentShell = shells.mCherry;
    end
    
    % -- Convolve over the points -- %
    % TODO: Different settings per channel
    %convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);
    
    % -- Compute mercator projections -- %
    mercatorProjections{j} = computeMercatorProjections(currentShell, option.shellHeatmapResolution);
    
    % -- Compute heatmaps -- %
    HMS = generateHeatmap(currentAccumulator,option.heatmaps.types);
    
    % -- fix paths in case we are generating for special channel --%
    heatmapsPath = strcat(p.resultsPath, "/heatmaps/", channels(j));
    if ~exist(strcat(heatmapsPath,"/"),'dir')
        mkdir(heatmapsPath);
    end
    % Save heatmap structure HMS
    if option.heatmaps.saveHMmat == 1
        mat_name = strcat(heatmapsPath,"/","Heatmap_Structure.mat");
        save(mat_name,'HMS');
    end
    
    % Save accumulator
    if option.heatmaps.saveAccumulator == 1
        mat_name = strcat(heatmapsPath,"/","Accumulator.mat");
        save(mat_name,'currentAccumulator');
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
            [f,pca] = creatStdFigure_scaled(numberOfResults,sum(currentAccumulator(:)),HMS,currentType);
            figs(i+(2*(i-1))) = copyobj(f,0);
            %set(findobj(figs(i+(2*(i-1))).Children,'Tag','sp3'),'position',pca); % TODO: IS THIS REALLY NEEDED?
            set(figs(i+(2*(i-1))),'Visible',vis);
            
            if option.heatmaps.save == 1
                for k=1:size(option.heatmaps.saveas,2)
                    fig_filename = strcat(heatmapsPath,"/",currentType,"_Heatmaps");
                    saveas(f,fig_filename,option.heatmaps.saveas{k});
                end
            end
        end
        if strcmp(option.heatmaps.scaled,'false')||strcmp(option.heatmaps.scaled,'both')
            % Create figure
            f = creatStdFigure_unscaled(numberOfResults,sum(currentAccumulator(:)),HMS,currentType);
            figs(i+1+(2*(i-1))) = copyobj(f,0);
            set(figs(i+1+(2*(i-1))),'Visible',vis);
            
            if option.heatmaps.save == 1
                for k=1:size(option.heatmaps.saveas,2)
                    fig_filename = strcat(heatmapsPath,"/",currentType,"_Heatmaps(unscaled)");
                    saveas(f,fig_filename,option.heatmaps.saveas{k});
                end
            end
        end
    end
    
    % -- if slider should be shown --  %
    
    if option.slider == 1
        disp('Slider');
        gui_slider(p,option,currentAccumulator,convAcc,numOfAllCells,numberOfResults);
    end
    
    % -- if cropper should be shown --  %
    
    if option.cropper == 1
        disp('Cropper');
        gui_cropRegion(currentAccumulator,HMS.MIP.Top,200);
    end
    
    
    % -- Determine maximum value in all heatmaps for easier comparison -- %
    maxi = -1;
    for i=1:size(mercatorProjections{j},3)
        projection = mercatorProjections{j}(:,:,i);
        tmp_max = max(projection(:));
        if maxi < tmp_max
            maxi = tmp_max;
        end
    end
    
    % -- Save shell heatmaps -- %
    f = figure;
    for i=1:size(mercatorProjections{j},3)
        imagesc(mercatorProjections{j}(:,:,i),[0 maxi]);
        saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
    end
    
end


%% create combined heatmaps

% PGCs + landmark
% -- Determine maximum value in all heatmaps for easier comparison -- %
heatmapsPath = strcat(p.resultsPath, "/heatmaps/PGC+landmark");
if ~exist(strcat(heatmapsPath,"/"),'dir')
        mkdir(heatmapsPath);
end
f = figure;
for i=1:size(mercatorProjections{3},3)
    fuse = imfuse(mercatorProjections{3}(:,:,i), mercatorProjections{1}(:,:,i));
    imagesc(fuse);
    saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
end


% nuclei + landmark
% -- Determine maximum value in all heatmaps for easier comparison -- %
heatmapsPath = strcat(p.resultsPath, "/heatmaps/nuclei+landmark");
if ~exist(strcat(heatmapsPath,"/"),'dir')
        mkdir(heatmapsPath);
end
f = figure;
for i=1:size(mercatorProjections{2},3)
    fuse = imfuse(mercatorProjections{2}(:,:,i), mercatorProjections{1}(:,:,i));
    imagesc(fuse);
    saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
end

end
