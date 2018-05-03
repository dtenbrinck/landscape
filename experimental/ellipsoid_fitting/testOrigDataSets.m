function testOrigDataSets()
    close all; 
    load("datasets.mat");
    for i=1:3
        fprintf("\n\n estimating embryo ellipsoids for data set " + num2str(i) + "...\n");
        X=datasets{i};
        outputPathBase = "Tests/ellipsoid_estimation_orig_data" + num2str(i);
        testOneDataSet(X, outputPathBase)  
    end

end

function testOneDataSet(X, outputPathBase)
    % test unreduced data set
    testDataSetWithRegularisationParams(10^-8, 0, 0.02, 1, X, [outputPathBase + "_unreduced"], 'ellipsoid estimations', 10^-8);
    % test reduced data set
    idx = randperm( size(X,1), ceil(0.2*size(X,1)));
    X = X(idx,:); 
    testDataSetWithRegularisationParams(10^-8, 0, 0.002, 1, X, [outputPathBase + "_reduced"], 'ellipsoid estimations', 10^-10);
end

function testDataSetWithRegularisationParams(mu0, mu1, mu2, mu3, X, outputPath, title, TOL_consecutiveIterates)
    regularisationParams.mu0 = mu0;
    regularisationParams.mu1 = mu1; 
    regularisationParams.mu2 = mu2; 
    regularisationParams.mu3 = mu3;
    regularisationParams.gamma = 1; 
    estimateEllipsoidForDataSetAndPlotResults(X, 'cg', regularisationParams, outputPath, 1 , title, TOL_consecutiveIterates);
end
