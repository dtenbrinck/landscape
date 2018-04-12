function testOrigDataSets()
    close all;   
    load('data.mat'); X=data;
    outputPathBase = 'regularisationTests/ellipsoid_estimation_';
    i=1;
%     testDataSetWithRegularisationParams(0.0002, 0.02, 0, 0, X, [outputPathBase num2str(i)], 'regularisation terms: equal raddii, small radii'); 
%     i=i+1;
%     testDataSetWithRegularisationParams(0.0002, 0.02, 1, 0, X, [outputPathBase num2str(i)], 'regularisation terms: equal raddii, small radii, small distances'); 
%     % good reference approximation with (...0.0002, 0.02, 1, 0,...)
%     i=i+1;
%     testDataSetWithRegularisationParams(0, 0.02, 1, 0, X, [outputPathBase num2str(i)], 'regularisation terms: small radii, small distances'); 
%     % same results as with first reg. param. as well so this one is neglectable
%     i=i+1;
    testDataSetWithRegularisationParams(0, 0.02, 10, 0, X, [outputPathBase num2str(i)], 'regularisation terms: small distances');
end

function testDataSetWithRegularisationParams(mu1, mu2, mu3, mu4, X, outputPath, title)
    regularisationParams.mu1 = mu1; 
    regularisationParams.mu2 = mu2; 
    regularisationParams.mu3 = mu3;
    regularisationParams.mu4 = mu4;
    regularisationParams.gamma = 1; 
    fprintf(['######################################### ' title]); 
    regularisationParams
    estimateEllipsoidForDataSetAndPlotResults(X, 'cg', regularisationParams, outputPath, 1 , title);
end

function estimateEllipsoidForDataSetAndPlotResultsWithOldEstimation(X, descentMethod, regularisationParams,datasetName, isPCAactive)
    [center, radii, axis, radii_ref, center_ref, radii_initial, center_initial] = getEllipsoidCharacteristicsInitialReferenceEstimation( X, descentMethod, 'sqr', regularisationParams, isPCAactive );
    %fprintf('\n');
    [center1, radii1, axis1, radii_ref1, center_ref1, radii_initial1, center_initial1] = getEllipsoidCharacteristicsInitialReferenceEstimation( X, descentMethod, 'log', regularisationParams, isPCAactive );
    table( radii_initial, radii, radii_ref, radii1, radii_ref1)
    % plot ellipsoid fittings
    %%fprintf('Plotting results...\n');
    figure('Name', "Scatter plot and resulting ellipsoid fittings for " + datasetName + ", PCA= " + isPCAactive,...
        'units','pixels','outerposition',[0 0 1800 1000]);
    subplot(1,2,1);
    hold on;
    titletext = 'Embryo estimations';
    plotSeveralEllipsoidEstimations(X, center_initial1, radii_initial1,...
        center1, radii1, center_ref1, radii_ref1, titletext, isPCAactive, axis);
    hold off;
    subplot(1,2,2);
    hold on;
    titletext = 'Embryo estimations';
    plotSeveralEllipsoidEstimations(X, center_initial1, radii_initial1,...
        center1, radii1, center_ref1, radii_ref1, titletext, isPCAactive, axis);
    view(3);
    hold off;
    print("results/ellipsoid_estimation_old_vs_new.png",'-dpng');
end
