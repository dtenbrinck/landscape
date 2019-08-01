function generateHeatmapsFromAccumulator(p)

%% LOAD ACCUMULATOR
load([p.resultsPath,'/AllAccumulators.mat']);

%% HANDLE HEATMAPS ( Computation, drawing and saving ) 
handleHeatmaps(accumulators,shells,numberOfResults,p);

%% USER OUTPUT
disp('All results in folder processed!');

end