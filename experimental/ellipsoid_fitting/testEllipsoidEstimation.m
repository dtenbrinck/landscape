function testEllipsoidEstimation
    close all;
    
    X = firstDataSet();
    fprintf('Expecting an ellipsoid with approx. radii=(1,1,1), center=(0,0,0)...\n');
    % TODO improve regularisation parameter and maybe vary eps
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', 10, 0.5, 1, 'data_set1' );
    
    % second test data set
    X = secondDataSet();
    fprintf('\n\nExpecting an ellipsoid with approx. radii=(4,2,1), center=(1,2,2)...\n');
    % TODO improve regularisation parameter and maybe vary eps
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', 4, 0.5, 1, 'data_set2' );
    
    % Manipulate second data set by rotating it around the coordinate axis
    Y = thirdDataSet(X);
    fprintf('\n\nExpecting an ellipsoid like the one before but rotatet around 45° in each direction...\n');
    % TODO improve regularisation parameter and maybe vary eps
%     estimateEllipsoidForDataSetAndPlotResults(Y, 'grad', 4, 0.5, 1, 'data_set3' );
end

function estimateEllipsoidForDataSetAndPlotResults(X, descentMethod, mu1, mu2, eps, picfilename)
    
    [center, radii, ~, v, radii_ref, center_ref, v_ref] = estimateMinimumEllipsoid( X, descentMethod, 'sqr', mu1, mu2, eps );
    fprintf('\n');
    [center1, radii1, ~, v1, radii_ref1, center_ref1, v_ref1] = estimateMinimumEllipsoid( X, descentMethod, 'log', mu1, mu2, eps );
    [radii_initial, center_initial, v_initial, ~] = initializeEllipsoidParams(X);
    table( radii_initial, radii, radii_ref, radii1, radii_ref1)
    table( center_initial, center, center_ref, center1, center_ref1 )
    %table( v_initial, v, v_ref, v1, v_ref1)

    % plot ellipsoid fittings
    figure('Name', 'Scatter plot and resulting ellipsoid fittings','units','normalized','outerposition',[0 0 1 1]);
    sp = subplot(1,2,1);
    titletext = 'Approximation of non differentiable term with (max(0,...))^2';
    plotSeveralEllipsoidEstimations(sp, X, center_initial, radii_initial, center, radii,  center_ref, radii_ref, titletext);
    sp = subplot(1,2,2);
    titletext = 'Approximation of non differentiable term with log(1+eps(...))';
    plotSeveralEllipsoidEstimations(sp, X, center_initial, radii_initial, center1, radii1, center_ref1, radii_ref1, titletext);
    print(['results/ellipsoid_estimation_' picfilename '.png'],'-dpng')
end

function plotSeveralEllipsoidEstimations(sp, X, center_initial, radii_initial, center, radii, center_ref, radii_ref, titletext)
    hold(sp, 'on');
    scatter3(X(:,1),X(:,2), X(:,3),'b','.', 'DisplayName', 'input data');
    plotOneEllipsoidEstimation( center_initial, radii_initial, 'g', 'initialization ellipsoid');
    plotOneEllipsoidEstimation( center, radii, 'm', 'ellipsoid estimation');
    plotOneEllipsoidEstimation( center_ref, radii_ref, 'c','reference estimation');
    legend('Location', 'northeast');
    title(titletext);
    view(3);
    hold(sp, 'off');
end

function plotOneEllipsoidEstimation( center, radii, color, displayname)
    if isreal(center) && isreal(radii)
        [x,y,z] = ellipsoid(center(1), center(2), center(3), radii(1), radii(2), radii(3), 20);
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