function testEllipsoidEstimation
    close all;    
%     testSampleTestCases();
    testOrigDataSet();
end

function testOrigDataSetWithRegularisation

end

function testOrigDataSet()
    load('data.mat'); X=data;
    % good regularisation params:
%     regularisationParams.mu1 = 0.0002; 
%     regularisationParams.mu2 = 0.02; 
%     regularisationParams.mu3 = 1;
%     regularisationParams.mu4 = 0;
    
    regularisationParams.mu1 = 0; 
    regularisationParams.mu2 = 0; 
    regularisationParams.mu3 = 0;
    regularisationParams.mu4 = 0;
    regularisationParams.gamma = 1; 
    fprintf('#########################################');
    regularisationParams
    estimateEllipsoidForDataSetAndPlotResults(X, 'cg', regularisationParams, 'data_set_orig_1_tests', 1 );  
end

function testSampleTestCases()
    X = firstDataSet();
    %fprintf('Expecting an ellipsoid with approx. radii=(1,1,1), center=(0,0,0)...\n');
    % TODO improve regularisation parameter and maybe vary gamma
    %fprintf('Without PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', 10, 0.5, 1, 'data_set1', 0 );
    %fprintf('With PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', 10, 0.5, 1, 'data_set1', 1 );
    
    % second test data set
    X = secondDataSet();
    %fprintf('\n\nExpecting an ellipsoid with approx. radii=(4,2,1), center=(1,2,2)...\n');
    % TODO improve regularisation parameter and maybe vary gamma
    %fprintf('Without PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', 4, 0.5, 1, 'data_set2', 0 );
    %fprintf('With PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', 4, 0.5, 1, 'data_set2', 1 );
    
    % Manipulate second data set by rotating it around the coordinate axis
    Y = thirdDataSet(X);
    %fprintf('\n\nExpecting an ellipsoid like the one before but rotated around 45� in each direction...\n');
    % TODO improve regularisation parameter and maybe vary gamma
    %fprintf('Without PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(Y, 'grad', 4, 0.5, 1, 'data_set3', 0 );
    %fprintf('With PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(Y, 'grad', 4, 0.5, 1, 'data_set3', 1 );
end

function estimateEllipsoidForDataSetAndPlotResults(X, descentMethod, regularisationParams,datasetName, isPCAactive)
    [center, radii, axis, radii_ref, center_ref, radii_initial, center_initial] = getEllipsoidCharacteristicsInitialReferenceEstimation( X, descentMethod, 'sqr', regularisationParams, isPCAactive );
    %fprintf('\n');
    [center1, radii1, axis1, radii_ref1, center_ref1, radii_initial1, center_initial1] = getEllipsoidCharacteristicsInitialReferenceEstimation( X, descentMethod, 'log', regularisationParams, isPCAactive );
%     table( radii_initial, radii, radii_ref, radii1, radii_ref1)
%     table( center_initial, center, center_ref, center1, center_ref1 )
%     volumes = 4/3*pi*[ prod(radii_initial), prod(radii), prod(radii_ref), prod(radii1), prod(radii_ref1)]
%       return;
    % plot ellipsoid fittings
    %fprintf('Plotting results...\n');
    figure('Name', "Scatter plot and resulting ellipsoid fittings for " + datasetName,...
        'units','pixels','outerposition',[0 0 1500 800]);
    subplot(1,2,1);
    hold on;
    titletext = {datasetName; 'Approximation of non differentiable term with (max(0,...))^2'};
    plotSeveralEllipsoidEstimations(X, center_initial, radii_initial,...
        center, radii,  center_ref, radii_ref, titletext, isPCAactive, axis);
    plotOrientationVectors( center, axis);
    hold off;
    subplot(1,2,2);
    hold on;
    titletext = {datasetName; 'Approximation of non differentiable term with log(1+gamma(...))'};
    plotSeveralEllipsoidEstimations(X, center_initial1, radii_initial1,...
        center1, radii1, center_ref1, radii_ref1, titletext, isPCAactive, axis);
    plotOrientationVectors( center1, axis1);
    hold off;
    descr = {['PCA= ' num2str(isPCAactive)]; 
        ['mu_1=' num2str(regularisationParams.mu1)]; 
        ['mu_2=' num2str(regularisationParams.mu2)]; 
        ['mu_3=' num2str(regularisationParams.mu3)]; 
        ['mu_4=' num2str(regularisationParams.mu4)]};
    yl=ylim;zl=zlim;
    text(0,yl(1)-200,zl(1)-250,descr);
%     print("results/ellipsoid_estimation_" + datasetName + ".png",'-dpng');
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

function plotOrientationVectors( center, axis)
    axis= 100*axis;
    quiver3( center(1), center(2), center(3), axis(1,1), axis(2,1), axis(3,1), 'k', 'LineWidth', 2, 'Displayname','first axis');
    quiver3( center(1), center(2), center(3), axis(1,2), axis(2,2), axis(3,2), 'r', 'LineWidth', 2, 'Displayname','second axis');
    quiver3( center(1), center(2), center(3), axis(1,3), axis(2,3), axis(3,3), 'b', 'LineWidth', 2, 'Displayname','third axis');
end

function plotSeveralEllipsoidEstimations(X, center_initial, radii_initial,...
        center, radii, center_ref, radii_ref, titletext, isPCAactive, axis)
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data', 'MarkerFaceAlpha',0.1);
    plotOneEllipsoidEstimation( center, radii, 'm', 'ellipsoid estimation', isPCAactive, axis);
    plotOneEllipsoidEstimation( center_ref, radii_ref, 'c','reference estimation', isPCAactive, axis);
    plotOneEllipsoidEstimation( center_initial, radii_initial, 'g', 'initialization ellipsoid', isPCAactive, axis);
    plotOldEllipsoidEstimation(X, [0.9100    0.4100    0.1700], 'old estimation');
    legend('Location', 'southoutside');
    title(titletext, 'Interpreter', 'none');
    view(90, 0);%(3);%
end

function plotOldEllipsoidEstimation(X, color, displayname)
    %fprintf('Using least squares approximation to estimate another reference ellipsoid...\n');
    [ center, radii, axes, ~, ~] = estimateEllipsoid( X, '' );
    plotOneEllipsoidEstimation( center, radii, color, displayname, 1, axes);
end

function plotOneEllipsoidEstimation( center, radii, color, displayname, isPCAactive, axis)
    if isreal(center) && isreal(radii)
        n = 20;
        [x,y,z] = ellipsoid(0, 0, 0, radii(1), radii(2), radii(3), n-1);
        if ( isPCAactive )
            rotatedCoordinates = axis' * [reshape(x,1,n*n); reshape(y,1,n*n); reshape(z,1,n*n)];
            x = reshape(rotatedCoordinates(1, : ), [n, n]);
            y = reshape(rotatedCoordinates(2, : ), [n, n]);
            z = reshape(rotatedCoordinates(3, : ), [n, n]);
        end
        x = x + center(1);
        y = y + center(2);
        z = z + center(3);
        surf(x,y,z, 'FaceAlpha',0.15, 'FaceColor', color, 'EdgeColor', 'none', 'DisplayName', displayname);
    end
end

function X = firstDataSet()
    % 10 data points on or near unit sphere
    X1= [ 
        1       0       0;      ...
        0       1       0;      ...
        0       0       1;      ...
        1       0.02    0;      ...
        1       0       0.02;  ...
        0.02    1       0;      ...
        0       1       0.02;  ...
        0.02    0       1;      ...
        0       0.02    1;      ...
        -0.01   1       -0.01;  ...
        -0.01   -0.01   1;      ...
        1       -0.001  -0.01;  ...
        2       0       0     ; ...
        0       0       1.01  ; ...
        0       1.01    0 ; ...
        1.01    0       0  ; ...
        0       0       0.99 ; ...
        0       0.99    0  ; ...
        0.99    0       0  ];
    X=[X1; -X1];
end

function X = secondDataSet()
    n = 20;
    [x,y,z] = ellipsoid(1,2,2,4,2,1,n-1);
    rng(1); 
    disturbance = rand(n*n,1);
    rng(1); 
    disturbance2 = randn(n*n,1);
    X = [reshape(x, n*n, 1) + disturbance, reshape(y, n*n,1) + disturbance2, reshape(z, n*n, 1) + disturbance];
    X=[X;  15 2 1; 2 6 26; 0 3 0 ; 0 22 3];
end

function Y = thirdDataSet(X)
    Rx = [ 1 0 0 ; 0 cosd(45) -sind(45); 0 sind(45) cosd(45)];
    Ry = [ cosd(45) 0 sind(45); 0 1 0; -sind(45) 0 cosd(45)];
    Rz = [ cosd(45) -sind(45) 0; sind(45) cos(45) 0; 0 0 1];
    Y = (Rx*Ry*Rz* X')';
end