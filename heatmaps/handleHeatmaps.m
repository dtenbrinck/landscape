function [  ] = handleHeatmaps( accumulators,shells,numberOfResults, p )
% This function will handle the heatmaps. It will compute and show
% different heatmaps depending on the given options in 'option'.

%% MAIN CODE

option = p.option;

channels = ["Landmark", "Nuclei", "CellsOfInterest"];
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
    %convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);
    
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
    % CONVOLUTION
    sigma = 0.5; %default 0.5
    gaussian = fspecial('gaussian', [17 17], sigma);
    %gaussian = gaussian(9,:);
    %gaussian = gaussian./(sum(gaussian(:)));
    for i=1:size(mercatorProjections{j},3)
         mercatorProjections{j}(:,:,i) = imfilter(mercatorProjections{j}(:,:,i),gaussian,'replicate');
         
         % normalize for relative measures
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
    disp(['Maximum cell density in channel ' channels(j) ' channel for this experiment is: ' num2str(maxi)]);
    %%%%% UNTIL HERE!
    
    % -- Save shell heatmaps -- %
    f = figure('visible', 'off');
    set(f,'color','none');
    f.PaperUnits = 'inches';
    f.PaperPosition = [0 0 6 6];
    
        
    for i=1:size(mercatorProjections{j},3)-1
        imagesc(mercatorProjections{j}(:,:,i),[0 maxi]); axis image; colorbar; axis off; colormap parula; if j == 3; title([num2str(numberOfResults),' Embryos, ',num2str(size(currentShell{i},2)),' Cells']); end
        saveas(f,strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".png"),'png');
        savefig(strcat(heatmapsPath,"/shellHeatmap_", num2str(i), ".fig"))
    end
    imagesc(mercatorProjections{j}(:,:,size(mercatorProjections{j},3)),[0 maxi]); axis image; colorbar; axis off; colormap parula; if j==3; title([num2str(numberOfResults),' Embryos, ',num2str(size(currentShell{4},2)),' Cells']); end
    saveas(f,strcat(heatmapsPath,"/Heatmap_total.png"),'png');
    savefig(strcat(heatmapsPath,"/Heatmap_total.fig"))
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
