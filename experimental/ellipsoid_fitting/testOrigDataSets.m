function testOrigDataSets()
    close all;   
    load('data.mat'); X=data;
    outputPathBase = 'regularisationTests/ellipsoid_estimation_orig_data';
    testDataSetWithRegularisationParams(0, 0.02, 1, 0, X, [outputPathBase], 'ellipsoid estimations');
end

function testDataSetWithRegularisationParams(mu1, mu2, mu3, mu4, X, outputPath, title)
    regularisationParams.mu1 = mu1; 
    regularisationParams.mu2 = mu2; 
    regularisationParams.mu3 = mu3;
    regularisationParams.mu4 = mu4;
    regularisationParams.gamma = 1; 
    fprintf(['######################################### ' title]); 
    regularisationParams
    estimateEllipsoidForDataSetAndPlotResults(X, 'grad', regularisationParams, outputPath, 1 , title);
end
