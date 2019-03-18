%% DESCRIPTION

%This script will calculate the shell (defined by min and max radius in the unit sphere) that
%contains the most landmark coordinates for each result file in the accepted folder. 
%It will print the average and mean shell in the command window. 
%You can choose to see all individual shells in the 'Parameters' section below. There you can also
%choose if and what kind of visualisation you want to see. The pictures
%show individual embryos (not averaged landmarks!).

%% INITIALIZATION

clear; clc; close all;

% define root directory
root_dir = pwd;

% add path for parameter setup
addpath([root_dir '/parameter_setup/']);

% load necessary variables
p = initializeScript('heatmap', root_dir);
%p2 = initializeScript('processing', root_dir); Q: How can I access both parameter scripts without having to choose folder twice? 

%% PARAMETERS for visualisation and more info

showAllRadii = 0; % =1: shows the radii of landmark shell for each embryo
visualisation = 1; % =1: shows pictures of landmark and landmark shell
visualisationType = 'all'; % set which landmark shell you want to see in visualisation (average, mean, individual, all)
amountOfPictures = 2; % set how many pictures you want to see in visualisation 

%% GET FILES TO PROCESS

% Get filenames of MAT files in selected folder
fileNames = getMATfilenames(p.resultsPathAccepted);
fileNames(strcmp(fileNames,'ParameterProcessing.mat')) = [];
fileNames(strcmp(fileNames,'ParameterHeatmap.mat')) = [];
fileNames(strcmp(fileNames,'HeatmapAccumulator.mat')) = [];

if p.random == 1
    fileNames = drawRandomNames(fileNames,p.numberOfRandom);
end
% Get number of experiments
numberOfResults = numel(fileNames);

% Check if any results have been found
if numberOfResults == 0
    disp('All results already processed or path to results folder wrong?');
    disp(resultsPathAccepted);
    return;
else
    disp([ num2str(numberOfResults) ' results found in folder for generating heat map.']);
end

%% MAIN CODE

%initialize 
radii = zeros(2,numberOfResults); %the matrix 'radii' will have the maximum radii in the
                                  %first row and the minimum radii in the second row. The i-th column refers to
                                  %the i-th embryo
average = [0,0];                 
var_average = 0;
var_mean = 0;

for result = 1:numberOfResults
    %Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    if isfield(gatheredData.registered, 'landmarkCentCoords')
        landmarkCoords = gatheredData.registered.landmarkCentCoords;
    else 
        disp('The landmark coordinates are not saved in this result files. Make sure to select data that was processed with the new  version of the processing script.');
        return
    end
    
    %compute all shells containing landmark coordinates depending on thickness and shift width
    shells = computeShells_Pia_alt(landmarkCoords,0.0608, 0.01216); 
    %shells = computeShells_Pia_alt(landmarkCoords, p2.option.shellThickness, p2.option.shellSHiftWidth);
     
    %get amount of landmark cells per shell
    landmarkCellsPerShell = zeros(1,size(shells,2)); 
        for j = 1: size(shells,2)
            landmarkCellsPerShell(j) = size(shells{j},2); 
        end
     
    %get the shell with the most landmark cells, TODO:What if there is more than one shell?      
    [M,I] = max(landmarkCellsPerShell);
    landmarkshell = I(1);
       
    %get radii defiing landmark shell
    %radii(1,i) = 1 - landmarkshell*p2.option.shellShiftWidth ;
    radii(1,result) = 1 - landmarkshell*0.01216 ; 
    %radii(2,i) = radii(1,i) - p2.option.shellThickness;
    radii(2,result) = radii(1,result) - 0.0608;
    
    %get average shell
    min_radius = radii(2,result);
    max_radius = radii(1,result);
    average = average + [1/numberOfResults*min_radius, 1/numberOfResults*max_radius];
end

    %get mean shell and variances
    sortedRadii = sort(radii'); 
    mean = sortedRadii(ceil(size(sortedRadii,1)/2),:);
    mean(:,[1 2]) = mean(:,[2 1]);
    for result = 1:numberOfResults 
        var_average = var_average + 1/numberOfResults*(average(1)-radii(2,result))^2;
        var_mean = var_mean + 1/numberOfResults*(mean(1)-radii(2,result))^2;
    end
    
%print sizes of interest in command window
if showAllRadii == 1
  radii
end
text = ['The average landmark shell is: minimum radius = ', num2str(average(1)), ', maximum radius = ', num2str(average(2))];
disp(text);
text = ['The variance of the average is: variance = ', num2str(var_average)];
disp(text);
text = ['The mean landmark shell is: minimum radius = ', num2str(mean(1)), ', maximum radius = ', num2str(mean(2))];
disp(text);
text = ['The variance of the mean value is: variance = ', num2str(var_mean)];
disp(text)

%% VISUALISATION

if visualisation == 1
    if amountOfPictures > numberOfResults
        amountOfPictures = numberOfResults; 
    end
for result = 1:amountOfPictures    
    % get landmark coordinates
    load([p.resultsPathAccepted,'/',fileNames{result,1}]);
    landmarkCoords = gatheredData.registered.landmarkCentCoords;
    landmarkCoords = landmarkCoords';
    % sampling sphere
    samples = 128; %samples = p2.samples_sphere;
    [alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,2*samples));
    Xs = sin(alpha) .* sin(beta);
    Ys = cos(beta);
    Zs = cos(alpha) .* sin(beta);
    %save sphere coordinates as N x 3 matrix
    sphereCoordinates = [Xs(:), Ys(:), Zs(:)];
    %calculate norm of coordinates
    normOfCoordinates = sqrt(sum(landmarkCoords'.^2,1));
    
    if isequal(visualisationType,'mean')
        min = mean(1);
        max = mean(2);
        name = 'yellow: mean shell';
    elseif isequal(visualisationType,'average')
        min = average(1);
        max = average(2);
        name = 'yellow: average shell';
    elseif isequal(visualisationType, 'individual')
        min = radii(2, result);
        max = radii(1, result);
        name = 'yellow: individual shell';  
    elseif isequal(visualisationType, 'all')
        individual_min = radii(2, result);
        individual_max = radii(1, result);
        average_min = average(1);
        average_max = average(2);
        mean_min = mean(1);
        mean_max = mean(2);
        name = 'Comparison of all shell methods. Yellow: Landmark shell';    
    end
    
    % get landmark coordinates in shell
    if isequal(visualisationType, 'all')
    landmarkInShell_mean = landmarkCoords';
    normOfCoordinates_mean = normOfCoordinates;
    landmarkInShell_mean(:,normOfCoordinates_mean < mean_min) = [];
    normOfCoordinates_mean(:,normOfCoordinates_mean < mean_min) = [];
    landmarkInShell_mean(:,normOfCoordinates_mean > mean_max) = [];
    normOfCoordinates_mean(:,normOfCoordinates_mean > mean_max) = [];
    landmarkInShell_mean = landmarkInShell_mean';
    
    landmarkInShell_average = landmarkCoords';
    normOfCoordinates_average = normOfCoordinates;
    landmarkInShell_average(:,normOfCoordinates_average < average_min) = [];
    normOfCoordinates_average(:,normOfCoordinates_average < average_min) = [];
    landmarkInShell_average(:,normOfCoordinates_average > average_max) = [];
    normOfCoordinates_average(:,normOfCoordinates_average > average_max) = [];
    landmarkInShell_average = landmarkInShell_average';
    
    landmarkInShell_individual = landmarkCoords';
    normOfCoordinates_individual = normOfCoordinates;
    landmarkInShell_individual(:,normOfCoordinates_individual < individual_min) = [];
    normOfCoordinates_individual(:,normOfCoordinates_individual < individual_min) = [];
    landmarkInShell_individual(:,normOfCoordinates_individual > individual_max) = [];
    normOfCoordinates_individual(:,normOfCoordinates_individual > individual_max) = [];
    landmarkInShell_individual = landmarkInShell_individual';
    else   
    landmarkInShell = landmarkCoords';   
    landmarkInShell(:,normOfCoordinates < min) = [];
    normOfCoordinates(:,normOfCoordinates < min) = [];
    landmarkInShell(:,normOfCoordinates > max) = [];
    normOfCoordinates(:,normOfCoordinates > max) = [];
    landmarkInShell = landmarkInShell';
    end
    
    % draw figure
    if isequal(visualisationType, 'all')
    %figure('Name', name);    
    figure('Name', name,'units','normalized', 'outerposition',[0.1 0.1 0.9 0.4]); 
    subplot(1,3,1);
        scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
        hold on
        scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
        hold on
        scatter3(landmarkInShell_individual(:,1),landmarkInShell_individual(:,2),landmarkInShell_individual(:,3), 100,'*');
        view(0,180);
        %view(0,90);
        title('individual')
    subplot(1,3,2);
        scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
        hold on
        scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
        hold on
        scatter3(landmarkInShell_mean(:,1),landmarkInShell_mean(:,2),landmarkInShell_mean(:,3), 100,'*');
        view(0,180);
        %view(0,90);
        title('mean')
    subplot(1,3,3);
        scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
        hold on
        scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
        hold on
        scatter3(landmarkInShell_average(:,1),landmarkInShell_average(:,2),landmarkInShell_average(:,3), 100,'*');
        view(0,180);
        %view(0,90);
        title('average')
    else
    figure('Name', name); scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
    hold on
    scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
    hold on
    scatter3(landmarkInShell(:,1),landmarkInShell(:,2),landmarkInShell(:,3), 100,'*');
    view(0,180);
    %view(0,90);
    drawnow;
    end
end    
end    
    