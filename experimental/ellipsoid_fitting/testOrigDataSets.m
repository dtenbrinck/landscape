function testOrigDataSets()
    close all;   
    load('data.mat'); X=data;
    outputPathBase = 'Tests/ellipsoid_estimation_orig_data';
%     idx = randperm( size(X,1), ceil(0.2*size(X,1)));
%     X = X(idx,:); 
%     testDataSetWithRegularisationParams(10^-8, 0, 0.007, 1, X, [outputPathBase], 'ellipsoid estimations');
    % regularisation params for unreduced data set
    testDataSetWithRegularisationParams(10^-8, 0, 0.02, 1, X, [outputPathBase], 'ellipsoid estimations');

end

function testDataSetWithRegularisationParams(mu0, mu1, mu2, mu3, X, outputPath, title)
    regularisationParams.mu0 = mu0;
    regularisationParams.mu1 = mu1; 
    regularisationParams.mu2 = mu2; 
    regularisationParams.mu3 = mu3;
    regularisationParams.gamma = 1; 
    estimateEllipsoidForDataSetAndPlotResults(X, 'cg', regularisationParams, outputPath, 1 , title);
end
