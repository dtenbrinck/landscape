function [  ] = handleHeatmaps( accumulators,shells, origSize_px, numberOfResults, p )
% This function will handle the heatmaps. It will compute and show
% different heatmaps depending on the given options in 'option'.

%% MAIN CODE

option = p.option;
if strcmp(p.mappingtype, 'Cells')
    channels = ["Landmark", "Nuclei", "CellsOfInterest"];
elseif strcmp(p.mappingtype, 'Tissue')
    channels = ["Landmark", "Nuclei", "TissueOfInterest"];
end
mercatorProjections = cell(1,3);

if option.heatmaps.saveAccumulator == 1
    save([p.resultsPath '/AllAccumulators.mat'],'accumulators','shells','numberOfResults');
end
   
% create directory for profile lines if it does not exist
if p.extractProfileLines
    profileLinesPath = strcat(p.resultsPath, "/heatmaps/profileLines");
    if ~exist(strcat(profileLinesPath,"/"),'dir')
        mkdir(profileLinesPath);
    end
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
    % convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1); 
    %
    % better: Gauss filter
    %cellDiameter = p.cellDiameter;
    %cellDiameter = p.gridSize(1)/p.scaledDataSize(1) * cellDiameter; %problem: accumulator/heatmap is a square while data is not. TODO: adjust accumulator/heatmap size to data size
    %sigma = cellDiameter/(2*sqrt(2*log(2))); 
    %for i=1:size(currentAccumulator,3)
         %currentAccumulator(:,:,i) = imgaussfilt(currentAccumulator(:,:,i), sigma); 
         
           %normalize for relative measures
        %currentAccumulator(:,:,i) = currentAccumulator(:,:,i) ./ sum(currentAccumulator(:));
    %end
   
    
    % -- Compute mercator projections -- %
    mercatorProjections{j} = computeMercatorProjections(currentShell, option.shellHeatmapResolution);
    
    % -- Extract plot lines -- %
    if j == 2 && p.extractProfileLines % we assume that the second channel is DAPI!
         %figure; imagesc(mercatorProjections{1}(:,:,5))
        %hold on; xline(28,'r'); xline(38,'r'); xline(48,'r'); hold off; %
        %for resolution = 90!
        profileLines = extractProfileLines(mercatorProjections{j});
        
        % save profile lines as csv files
        for shell=1:size(profileLines,3)
            %writematrix(profileLines(:,:,shell),strcat(profileLinesPath,"/","shell_",num2str(shell),".csv"));
            csvwrite(strcat(profileLinesPath,"/","shell_",num2str(shell),".csv"),profileLines(:,:,shell)) ;
        end
    end
    
    % -- Compute heatmaps -- %
    %DISABLED FOR DEMO
    %HMS = generateHeatmap(currentAccumulator,option.heatmaps.types);
    
    % -- fix paths in case we are generating for special channel --%
    heatmapsPath = strcat(p.resultsPath, "/heatmaps/", channels(j));
    if ~exist(strcat(heatmapsPath,"/"),'dir')
        mkdir(heatmapsPath);
    end
    % Save heatmap structure HMS
    %if option.heatmaps.saveHMmat == 1
    %    mat_name = strcat(heatmapsPath,"/","Heatmap_Structure.mat");
    %    save(mat_name,'HMS');
    %end
    
    % Save accumulator
    if option.heatmaps.saveAccumulator == 1
        mat_name = strcat(heatmapsPath,"/","Accumulator.mat");
        save(mat_name,'currentAccumulator');
    end
    %{
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
    %}
       
    %CONVOLUTION 
    
    try
        cellDiameter = p.cellDiameter;
        cellDiameter = p.option.shellHeatmapResolution(1)/origSize_px(1) * cellDiameter; %problem: accumulator/heatmap is a square while data is not. TODO: adjust accumulator/heatmap size to data size
        sigma = cellDiameter/(2*sqrt(2*log(2)));
        if sigma == Inf
            disp('Cell diameter not found because you are only using accumulator files. Using standard settings. ')
            sigma = 0.5;
        end    
    catch
        disp('Cell diameter not found because you are using old data. Using standard settings. ')
        sigma = 0.5; %default
    end 
    
    for i=1:size(mercatorProjections{j},3)
         mercatorProjections{j}(:,:,i) = imgaussfilt(mercatorProjections{j}(:,:,i), sigma); 
         
         %normalize for relative measures
         mercatorProjections{j}(:,:,i) = mercatorProjections{j}(:,:,i) ./ sum(currentAccumulator(:));
    end
    
    % -- Determine maximum value in all heatmaps for easier comparison -- %
    % HERE YOU CAN SET THE MAXIMUM VALUE MANUALLY BASED ON THE MAXIMUM
    % NUMBER OF CELLS IN ALL SHELLS (COMPARISON WITH OTHER EXPERIMENTS)
    
    %maxi{1} = 0.001774;
    %maxi{2} = 0.001774;
    %maxi{3} = 0.001774;
    
    %maxi = 0.0052194;%maxi{j};
    
    %%%%% THIS CAN BE COMMENTED OUT AFTERWARDS!
    maxi = -1;
    for i=1:size(mercatorProjections{j},3)-1
        projection = mercatorProjections{j}(:,:,i);
        tmp_max = max(projection(:));
        if maxi < tmp_max
            maxi = tmp_max;
        end
    end
    %for debugging only
    %disp(['Maximum cell density in channel ' channels(j) ' channel for this experiment is: ' num2str(maxi)]);
    %%%%% UNTIL HERE!
    
    % -- Save shell heatmaps -- %
    f = figure('visible', 'off');
    a = axes(f);
    %f = figure(100);
    set(f,'color','none');
   
    f.PaperUnits = 'inches';
    f.PaperPosition = [0 0 6 6];
    pause(0.1);
     set(0, 'CurrentFigure', f)
    
    switch j
        case 1 %GFP
            for i=1:size(mercatorProjections{j},3)-1
                imagesc(mercatorProjections{j}(:,:,i),'parent',a,[0 maxi]); axis image; colorbar(a); axis off; colormap(a,parula); title(a,[num2str(numberOfResults),' embryo(s)']);
                pause(0.1)
                text(a,1.25,0.5,'abundance', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'center');
                text(a,-0.1,1,'\rightarrow Right', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'right');
                text(a,-0.1,0,'Left \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'left');
                text(a,0,-0.12,'Anterior \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'left');
                text(a,1,-0.12,'\rightarrow Posterior', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'right');
                if any(strcmp(p.option.heatmaps.saveas, 'png'))
                    saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
                end
                if any(strcmp(p.option.heatmaps.saveas, 'fig'))
                    savefig(strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".fig"))
                end
            end
            imagesc(mercatorProjections{j}(:,:,size(mercatorProjections{j},3)),'parent',a,[0 maxi]); axis image; colorbar(a); axis off; colormap(a,parula); title(a,[num2str(numberOfResults),' embryo(s)']);
            pause(0.1)
            text(a,1.25,0.5,'abundance', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'center');
            text(a,-0.1,1,'\rightarrow Right', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'right');
            text(a,-0.1,0,'Left \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'left');
            text(a,0,-0.12,'Anterior \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'left');
            text(a,1,-0.12,'\rightarrow Posterior', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'right');
            if any(strcmp(p.option.heatmaps.saveas, 'png'))
                saveas(f,strcat(heatmapsPath,"/Heatmap_total.png"),'png');
            end
            if any(strcmp(p.option.heatmaps.saveas, 'fig'))
                savefig(strcat(heatmapsPath,"/Heatmap_total.fig"))
            end
    
        case 2 %DAPI
            for i=1:size(mercatorProjections{j},3)-1
                imagesc(mercatorProjections{j}(:,:,i),'parent',a,[0 maxi]); axis image; colorbar(a); axis off; colormap(a,parula); title(a,[num2str(numberOfResults),' embryo(s), ',num2str(size(currentShell{i},2)),' cell(s)']);
                pause(0.1)
                text(a,1.25,0.5,'abundance', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'center');
                text(a,-0.1,1,'\rightarrow Right', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'right');
                text(a,-0.1,0,'Left \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'left');
                text(a,0,-0.12,'Anterior \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'left');
                text(a,1,-0.12,'\rightarrow Posterior', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'right');
                if any(strcmp(p.option.heatmaps.saveas, 'png'))
                    saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
                end
                if any(strcmp(p.option.heatmaps.saveas, 'fig'))
                    savefig(strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".fig"))
                end
                if option.heatmaps.saveCSV
                    if exist('writematrix','file') == 2
                        writematrix(mercatorProjections{j}(:,:,i),strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".csv"));
                    else
                        csvwrite(strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".csv"),mercatorProjections{j}(:,:,i));
                    end
                end
            end
            imagesc(mercatorProjections{j}(:,:,size(mercatorProjections{j},3)),'parent',a,[0 maxi]); axis image; colorbar(a); axis off; colormap(a,parula); title(a,[num2str(numberOfResults),' embryo(s), ',num2str(size(currentShell{4},2)),' cell(s)']);
            pause(0.1)
            text(a,1.25,0.5,'abundance', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'center');
            text(a,-0.1,1,'\rightarrow Right', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'right');
            text(a,-0.1,0,'Left \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'left');
            text(a,0,-0.12,'Anterior \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'left');
            text(a,1,-0.12,'\rightarrow Posterior', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'right');
            if any(strcmp(p.option.heatmaps.saveas, 'png'))
                saveas(f,strcat(heatmapsPath,"/Heatmap_total.png"),'png');
            end
            if any(strcmp(p.option.heatmaps.saveas, 'fig'))
                savefig(strcat(heatmapsPath,"/Heatmap_total.fig"))
            end
            if option.heatmaps.saveCSV
                if exist('writematrix','file') == 2
                        writematrix(mercatorProjections{j}(:,:,i),strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".csv"));
                else
                        csvwrite(strcat(heatmapsPath,"/Heatmap_total.csv", ".csv"),mercatorProjections{j}(:,:,i));
                end
            end
            
            
        case 3 %mCherry
            for i=1:size(mercatorProjections{j},3)-1
                imagesc(mercatorProjections{j}(:,:,i),'parent',a,[0 maxi]); axis image; colorbar(a); axis off; colormap(a,parula);
                if strcmp(p.mappingtype, 'Cells') 
                    title(a,[num2str(numberOfResults),' embryo(s), ',num2str(size(currentShell{i},2)),' cell(s)']); 
                else
                    title(a,[num2str(numberOfResults),' embryo(s)']);
                end
                pause(0.1)
                text(a,1.25,0.5,'abundance', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'center');
                text(a,-0.1,1,'\rightarrow Right', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'right');
                text(a,-0.1,0,'Left \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'left');
                text(a,0,-0.12,'Anterior \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'left');
                text(a,1,-0.12,'\rightarrow Posterior', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'right');
                if any(strcmp(p.option.heatmaps.saveas, 'png'))
                    saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
                end
                if any(strcmp(p.option.heatmaps.saveas, 'fig'))
                    savefig(strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".fig"))
                end
                if option.heatmaps.saveCSV
                     if exist('writematrix','file') == 2
                        writematrix(mercatorProjections{j}(:,:,i),strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".csv"));
                    else
                        csvwrite(strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".csv"),mercatorProjections{j}(:,:,i));
                     end
                end
            end
            imagesc(mercatorProjections{j}(:,:,size(mercatorProjections{j},3)),'parent',a,[0 maxi]); axis image; colorbar(a); axis off; colormap(a,parula);
            if strcmp(p.mappingtype, 'Cells') 
                    title(a,[num2str(numberOfResults),' embryo(s), ',num2str(size(currentShell{4},2)),' cell(s)']);
                else
                    title(a,[num2str(numberOfResults),' embryo(s)']);
                end
            pause(0.1)
            text(a,1.25,0.5,'abundance', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'center');
            text(a,-0.1,1,'\rightarrow Right', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'right');
            text(a,-0.1,0,'Left \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'rotation', 90, 'HorizontalAlignment', 'left');
            text(a,0,-0.12,'Anterior \leftarrow', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'left');
            text(a,1,-0.12,'\rightarrow Posterior', 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 15, 'HorizontalAlignment', 'right');
            if any(strcmp(p.option.heatmaps.saveas, 'png'))
                saveas(f,strcat(heatmapsPath,"/Heatmap_total.png"),'png');
            end
            if any(strcmp(p.option.heatmaps.saveas, 'fig'))
                savefig(strcat(heatmapsPath,"/Heatmap_total.fig"))
            end
            if option.heatmaps.saveCSV
                if exist('writematrix','file') == 2
                        writematrix(mercatorProjections{j}(:,:,i),strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".csv"));
                else
                        csvwrite(strcat(heatmapsPath,"/Heatmap_total.csv", ".csv"),mercatorProjections{j}(:,:,i));
                end
            end
    end
    close(f);
end


%% create combined heatmaps
%DISABLED FOR DEMO
%{
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
%}
end
