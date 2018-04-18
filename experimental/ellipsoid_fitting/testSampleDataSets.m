function testSampleDataSets()
    close all;
    X = firstDataSet();
    %fprintf('Expecting an ellipsoid with approx. radii=(1,1,1), center=(0,0,0)...\n'); 
    regularisationParams.mu1 = 10; 
    regularisationParams.mu2 = 0.5; 
    regularisationParams.mu3 = 0;
    regularisationParams.gamma = 1; 
    title = 'ellipsoid_estimation_data_set1';
    estimateEllipsoidWithAndWithoutPCA(X, regularisationParams, title);
    
    % second test data set
    X = secondDataSet();
    %fprintf('\n\nExpecting an ellipsoid with approx. radii=(4,2,1), center=(1,2,2)...\n'); 
    regularisationParams.mu1 = 4; 
    title = 'ellipsoid_estimation_data_set2';
    estimateEllipsoidWithAndWithoutPCA(X, regularisationParams, title);
    
    % Manipulate second data set by rotating it around the coordinate axis
    Y = thirdDataSet(X);
    %fprintf('\n\nExpecting an ellipsoid like the one before but rotated around 45° in each direction...\n');
    title = 'ellipsoid_estimation_data_set3';
    estimateEllipsoidWithAndWithoutPCA(Y, regularisationParams, title);
end

function estimateEllipsoidWithAndWithoutPCA(X, regularisationParams, title)
    %fprintf('Without PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', regularisationParams, title, 0 , title);
    %fprintf('With PCA...\n');
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', regularisationParams, title, 1 , title);
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