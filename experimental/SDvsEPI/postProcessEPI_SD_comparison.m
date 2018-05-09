function postProcessEPI_SD_comparison

%% INITIALIZATION
clear; clc; close all;

% define root directory
root_dir = fileparts(fileparts(pwd));

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initialization(root_dir);


%% GET FILES TO PROCESS

% check results directory
checkDirectory(p.resultsPath);

% get filenames of STK files in selected folder
fileNames = getMATfilenames(p.resultsPath);
fileNames(find(strcmp(fileNames,'ParameterProcessing.mat'))) = [];
fileNames(find(strcmp(fileNames,'ParameterHeatmap.mat'))) = [];
% get number of experiments
numberOfResults = size(fileNames,1);

% check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(p.resultsPath);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for visualization.']);
end

%% MAIN EVALUATION LOOP

visualization = '3D_plot_ellipsoid';%'3D_plots', 'MIPs', '3D_plot_ellipsoid', 'GFP';
result = 0;
numberOfExperiments = numberOfResults/2;

while result < numberOfExperiments
    
    result = result + 1;
    % load EPI result data
    load([p.resultsPath,'/',fileNames{result,1}])
    gatheredDataEPI = gatheredData;
    
    % load SD result data
    load([p.resultsPath,'/',fileNames{result + numberOfExperiments,1}])
    gatheredDataSD = gatheredData;
    fprintf(['Generating plots for ' gatheredDataSD.filename ' and ' gatheredDataEPI.filename '...\n']);
    color = ['m', 'c'];
    if strcmp(visualization,'3D_plots')
        h1 = figure('units','normalized','outerposition',[0 0 1 0.7]);
        visualize_SD_and_EPI(h1, gatheredDataEPI, gatheredDataSD, result, p.resolution, color);
        print([p.resultsPath '/pngs/comparison_SD_EPI_mcherryCells_exp' num2str(result+1) '.png'],'-dpng');
    end
    
    if strcmp(visualization,'3D_plot_ellipsoid')
        h2 = figure('units','normalized','outerposition',[0 0 1 0.7]);
        handles = visualize_SD_and_EPI(h2, gatheredDataEPI, gatheredDataSD, result, p.resolution, color);
        addEllipsoids(h2, handles, gatheredDataEPI, gatheredDataSD, p.resolution, color);
        print([p.resultsPath '/pngs/SD_EPI_ellipsoid_mcherryCells_exp' num2str(result+1) '.png'],'-dpng');
    end
    
    if strcmp(visualization,'MIPs')
        f = figure('units','normalized','outerposition',[0 0 0.7 1]); 
        MIPs_SD_and_EPI_mCherry (f, gatheredDataEPI, gatheredDataSD, result);
        print([p.resultsPath '/pngs/MIPs_SD_EPI_mcherryCells_exp' num2str(result+1) '.png'],'-dpng');
    %     print([p.resultsPath '/pngs/MIPs_SD_EPI_mcherryCells_exp' num2str(result+1) '_colorbar.png'],'-dpng');
    end
    
    if strcmp(visualization,'GFP')
        f = figure('units','normalized','outerposition',[0 0 0.7 0.7]);
        plot_GFP(f, gatheredDataEPI, gatheredDataSD);
        print([p.resultsPath '/pngs/MIPs_SD_EPI_GFP_exp' num2str(result+1) '_colorbar.png'],'-dpng');
    end
end
%close all;
fprintf('\n');
disp('All results visualized');
end

%% visualizations
function MIPs_SD_and_EPI_mCherry (f, gatheredDataEPI, gatheredDataSD, counter)
    clf(f)
    % visualize original data
    pos = [0.03 0.1+0.6 0.45 0.28];
    subplot('Position', pos); imagesc((gatheredDataEPI.experiment.mCherryMIP)); title(['EPI - original data mCherry channel, embryo ' num2str( counter+1)] );
    %colorbar;
    pos = [0.03+0.5 0.1+0.6 0.45 0.28];
    subplot('Position', pos); imagesc((gatheredDataSD.experiment.mCherryMIP)); title(['SD - original data mCherry channel, embryo ' num2str( counter+1) ]);
    %colorbar;
    
    % visualize segmentation results in preprocessed data
    pos = [0.03 0.07+0.3 0.45 0.28];
    subplot('Position', pos); imagesc((gatheredDataEPI.processed.mCherryMIP)); title('EPI - Segmentation in processed mCherry channel');
    hold on; contour((gatheredDataEPI.processed.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    %colorbar;
    pos = [0.03+0.5 0.07+0.3 0.45 0.28];
    subplot('Position', pos); imagesc((gatheredDataSD.processed.mCherryMIP)); title('SD - Segmentation in processed mCherry channel');
    %colorbar;
    hold on; contour((gatheredDataSD.processed.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

    % visualize segmentation results in registered data
    pos = [0.03 0.03 0.45 0.28];
    subplot('Position', pos);  imagesc((gatheredDataEPI.registered.mCherryMIP)); title('EPI - Segmentation in registered mCherry channel'); axis image;
    %colorbar;
    hold on; contour((gatheredDataEPI.registered.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    pos = [0.03+0.5 0.03 0.45 0.28];
    subplot('Position', pos); imagesc((gatheredDataSD.registered.mCherryMIP)); title('SD - Segmentation in registered mCherry channel'); axis image;
    %colorbar;
    hold on; contour((gatheredDataSD.registered.cellsMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    drawnow;
end

function addEllipsoids(h, handles, gatheredDataEPI, gatheredDataSD, resolution, color)
    ellipsoid{1} = gatheredDataEPI.processed.ellipsoid;
    ellipsoid{2} = gatheredDataSD.processed.ellipsoid;
    
    sp_processed = handles.sp1;
    sp_registered = handles.sp2;
    
    set(h, 'currentaxes', sp_processed);
    [x1,y1,z1] = meshgrid(1:size(gatheredDataEPI.processed.Dapi,2),1:size(gatheredDataEPI.processed.Dapi,1),1:size(gatheredDataEPI.processed.Dapi,3));
    x = resolution(1) * x1;
    y = resolution(2) * y1;
    z = resolution(3) * z1;
    displayName={'estimated ellipsoid (EPI)', 'estimated ellipsoid (SD)'};
    for i=1:2
        v = ellipsoid{i}.v;
        Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
            2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
            2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
        %hold(sp_processed, 'on');
        % draw estimates embryo surface
        p = patch(isosurface( x, y, -z, Ellipsoid, -1*v(10) ));
        set( p, 'FaceAlpha', .15, 'FaceColor', color(i), 'EdgeColor', 'none', 'DisplayName', displayName{i} );
    end
    
    set(h, 'currentaxes', sp_registered);
    hold on;
    [X, Y, Z] = sphere(50);
    surf(X, Y, Z,'FaceAlpha', .15, 'FaceColor', 'b', 'EdgeColor', 'none', 'DisplayName', 'unit sphere' );
    
end

function handles = visualize_SD_and_EPI(f, gatheredDataEPI, gatheredDataSD, counter, resolution, color)

    clf(f);
    
    pos = [0.05 0.1 0.4 0.8];
    sp1 = subplot('Position', pos);
   
    pgc_coord_EPI = gatheredDataEPI.processed.cellCoordinates .* (resolution'*ones(1,size(gatheredDataEPI.processed.cellCoordinates, 2)));
    pgc_coord_SD = gatheredDataSD.processed.cellCoordinates .* (resolution'*ones(1,size(gatheredDataSD.processed.cellCoordinates, 2)));
    
    subplotPGC_coords(pgc_coord_EPI, pgc_coord_SD, sp1, color); 
    addLegends( gatheredDataEPI.filename,  gatheredDataSD.filename, counter);    
    title('Comparison of *processed* mCherry cells with EPI and SD microscopy', 'Interpreter', 'tex');
    xlabel('µm');
    ylabel('µm');
    zlabel('µm');
    xlim([0 resolution(1) * max(size(gatheredDataEPI.processed.mCherry, 2), size(gatheredDataSD.processed.mCherry, 2))]);
    ylim([0 resolution(2) * max(size(gatheredDataEPI.processed.mCherry, 1), size(gatheredDataSD.processed.mCherry, 1))]);
    zlim([-resolution(3) * max(size(gatheredDataEPI.processed.mCherry, 3), size(gatheredDataSD.processed.mCherry, 3)) 0]);
    
    pos = [0.05+0.5 0.1 0.4 0.8];
    sp2 = subplot('Position', pos);
    pgc_coord_EPI = gatheredDataEPI.registered.cellCoordinates;
    pgc_coord_SD = gatheredDataSD.registered.cellCoordinates;

    subplotPGC_coords(pgc_coord_EPI, pgc_coord_SD, sp2, color);
    addLegends( gatheredDataEPI.filename,  gatheredDataSD.filename, counter);    
    
    max_distances = pdist2( pgc_coord_EPI', pgc_coord_SD', 'euclidean','Smallest', min(length(pgc_coord_EPI), length(pgc_coord_SD)));
    txt = {'Comparison of *registered* mCherry cells with EPI and SD microscopy'; ['sum of distances: ' num2str(sum(max_distances(1,:))) ...
        ', max. distance: ' num2str(max(max_distances(1,:))) ...
        ', mean distance: ' num2str(mean(max_distances(1,:)))]};
    title(txt,  'Interpreter', 'tex');
%     xlabel({['sum of distances: ' num2str(sum(max_distances(1,:)))]; ...
%         ['max. distance: ' num2str(max(max_distances(1,:)))]; ...
%         ['mean distance: ' num2str(mean(max_distances(1,:)))]});
    xlim([-1.5; 1.5]); ylim([-1.5; 1.5]); zlim([-1.5; 1.5]);
    hold off;
    
    handles.sp1 = sp1;
    handles.sp2 = sp2;
end

function addLegends(filename_EPI,  filename_SD, counter)
    legend( 'Location', 'eastoutside',  [filename_EPI ' (embryo  ' num2str( counter+1) ')'],[ filename_SD ' (embryo  ' num2str( counter+1) ')']);
    l = legend('boxoff');
    set(l, 'Interpreter', 'none');  
end

function subplotPGC_coords (pgc_coord_EPI, pgc_coord_SD, sp, color)
    scatter3(pgc_coord_EPI(1,:), ...
        pgc_coord_EPI(2,:), ...
        -pgc_coord_EPI(3,:), ...
        color(1),'*');
    hold on;
    scatter3(pgc_coord_SD(1,:), ...
        pgc_coord_SD(2,:), ...
        -pgc_coord_SD(3,:), ...
        color(2),'*');
    view( -70, 40 );
    hold off;
end

function plot_GFP(f, gatheredDataEPI, gatheredDataSD)
    clf(f)
    
    % visualize segmentation results in preprocessed data
    pos = [0.03 0.53 0.4 0.4];
    subplot('Position', pos); imagesc((gatheredDataEPI.processed.GFPMIP)); title('EPI - Segmentation in processed GFP channel');
    colorbar;
    hold on; contour((gatheredDataEPI.processed.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

    pos = [0.03+0.5 0.53 0.4 0.4];
    subplot('Position', pos); imagesc((gatheredDataSD.processed.GFPMIP)); title('SD - Segmentation in processed GFP channel');
    colorbar;
    hold on; contour((gatheredDataSD.processed.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;

    % visualize segmentation results in registered data
    pos = [0.03 0.03 0.4 0.4];
    subplot('Position', pos);  imagesc((gatheredDataEPI.registered.GFPMIP)); title('EPI - Segmentation in registered GFP channel'); axis image;
    colorbar;
    hold on; contour((gatheredDataEPI.registered.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;    %colorbar;
    pos = [0.03+0.5 0.03 0.4 0.4];
    subplot('Position', pos); imagesc((gatheredDataSD.registered.GFPMIP)); title('SD - Segmentation in registered GFP channel'); axis image;
    colorbar;
    hold on; contour((gatheredDataSD.registered.landmarkMIP), [0.5 0.5], 'r', 'LineWidth', 2); hold off;
    drawnow;

end

%% initialization
function [ p ] = initialization( root_dir )
    % Initializes the scripts
    
    % add necessary folders
    addpath([root_dir '/auxiliary/']);
    addpath([root_dir '/fitting/']);
    addpath([root_dir '/gui/']);
    addpath([root_dir '/heatmaps/']);
    addpath([root_dir '/io/']);
    addpath([root_dir '/preprocessing/']);
    addpath([root_dir '/registration/']);
    addpath(genpath([root_dir '/segmentation/']));
    addpath([root_dir '/visualization/']);
    
    % set default search path for results
%     resultsPath = 'D:\CiM\imaging-zebrafish\Mikroskopiedaten\SDvsEpi\10um_slices\Results_Biologists\10um_epi_sd_results';
    resultsPath = '/media/piradmin/4TB/data/Landscape/Static/SDvsEpi/2017_10_13_ody_10hpf_SDvsEpi/10um_slices/10um_sd_and_epi_sortedResults';
    if exist([resultsPath,'/ParameterProcessing.mat'],'file') == 2
        load([resultsPath,'/ParameterProcessing.mat']);
    else
        p = ParameterProcessing();
    end
     p.resultsPath = resultsPath;
end

