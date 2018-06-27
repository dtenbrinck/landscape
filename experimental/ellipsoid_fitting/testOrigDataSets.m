function testOrigDataSets()
    close all; 
    load("datasets.mat");
    for i=1:3
        X=datasets{i};
        outputPathBase = "Tests/ellipsoid_estimation_orig_data" + num2str(i);
        testOneDataSet(X, outputPathBase, i)  
    end

end

function testOneDataSet(X, outputPathBase, i)
    fprintf("\n###### Estimating embryo ellipsoid for *unreduced* data set " + num2str(i) + "...\n");
    % test unreduced data set
    testDataSetWithRegularisationParams(10^-8, 0.02, 1, X, ...
        outputPathBase + "_unreduced", ...
        "ellipsoid estimations - dataset " + num2str( i ));
    % test reduced data set
    fprintf("###### Estimating embryo ellipsoid for *reduced* data set " + num2str(i) + "...\n");
    percentage = 10;
    idx = randperm( size(X,1), ceil(percentage/100*size(X,1)));
    X = X(idx,:); 
    testDataSetWithRegularisationParams(10^-8, 0.002, 1, X, ...
        [outputPathBase + "_reduced"], ...
        "ellipsoid estimations - " + percentage + "% of dataset " + num2str( i ));
end

function testDataSetWithRegularisationParams(mu0, mu1, mu2, X, outputPath, title)
    regularisationParams.mu0 = mu0; 
    regularisationParams.mu1 = mu1;
    regularisationParams.mu2 = mu2;
    regularisationParams.gamma = 1; 
    ellipsoidFitting.regularisationParams = regularisationParams;
    ellipsoidFitting.descentMethod = 'cg';
    estimateEllipsoidForDataSetAndPlotResults(X, ellipsoidFitting, outputPath, title);
end
