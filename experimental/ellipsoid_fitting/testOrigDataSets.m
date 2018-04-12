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
    testDataSetWithRegularisationParams(0, 0.02, 1, 0, X, [outputPathBase num2str(i)], 'test regularisation parameter');
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
