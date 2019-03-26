function [minRadius, maxRadius] = computeLandmarkShell(p, fileNames, numberOfResults)

%% MAIN CODE
%visualisation = 0;
debug = 1;

%initialize 
radii = zeros(2,numberOfResults); %the matrix 'radii' will have the maximum radii in the
                                  %first row and the minimum radii in the second row. The i-th column refers to
                                  %the i-th embryo

for result = 1:numberOfResults
    %Load result data
    load([p.resultsPathAccepted,'/',fileNames{result,1}])
    
    if isfield(gatheredData.registered, 'landmarkCentCoords')
        landmarkCoords = gatheredData.registered.landmarkCentCoords;
    else 
        disp('The landmark coordinates are not saved in this result files. Make sure to select data that was processed with the new  version of the processing script.');
        return
    end
    
    %compute all shells containingshowAllRadii landmark coordinates depending on thickness and shift width
    [shells, maxDistance] = computeShells(landmarkCoords,p.option.shellThickness, p.option.shellShiftWidth); 
     
    %get amount of landmark cells per shell
    landmarkCellsPerShell = zeros(1,size(shells,2)); 
    for j = 1: size(shells,2)
        landmarkCellsPerShell(j) = size(shells{j},2);
    end
     
    %get the shell with the most landmark cells, TODO:What if there is more than one shell?      
    [M,I] = max(landmarkCellsPerShell);
    landmarkshell = I(1);
       
    %get radii defining landmark shell
    radii(1,result) = maxDistance - (landmarkshell-1)*p.option.shellShiftWidth ; 
    radii(2,result) = radii(1,result) - p.option.shellThickness;

end

    %get mean shell and variances
    mean_radii = mean(radii,2);
    std_radii = sqrt(var(radii,0,2)); % both are equal as they have a fixed distance!
   
    
%print sizes of interest in command window
if debug == 1
  text = ['The average landmark shell is: minimum radius = ', num2str(mean_radii(2)), ', maximum radius = ', num2str(mean_radii(1))];
    disp(text);
    text = ['The standard deviation of the landmark shells is: ', num2str(std_radii(1))];
    disp(text);
end

minRadius = mean_radii(2);
maxRadius = mean_radii(1);

%% VISUALISATION
% TODO: Put into extra visualization function

% if visualisation == 1
%     if amountOfPictures > numberOfResults
%         amountOfPictures = numberOfResults; 
%     end
% for result = 1:amountOfPictures    
%     % get landmark coordinates
%     load([p.resultsPathAccepted,'/',fileNames{result,1}]);
%     landmarkCoords = gatheredData.registered.landmarkCentCoords;
%     landmarkCoords = landmarkCoords';
%     % sampling sphere
%     samples = 128; %samples = p2.samples_sphere;
%     [alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,2*samples));
%     Xs = sin(alpha) .* sin(beta);
%     Ys = cos(beta);
%     Zs = cos(alpha) .* sin(beta);
%     %save sphere coordinates as N x 3 matrix
%     sphereCoordinates = [Xs(:), Ys(:), Zs(:)];
%     %calculate norm of coordinates
%     normOfCoordinates = sqrt(sum(landmarkCoords'.^2,1));
%     
%     if isequal(visualisationType,'mean')
%         mini = mean(1);
%         maxi = mean(2);
%         name = 'yellow: mean shell';
%     elseif isequal(visualisationType,'average')
%         mini = average(1);
%         maxi = average(2);
%         name = 'yellow: average shell';
%     elseif isequal(visualisationType, 'individual')
%         mini = radii(2, result);
%         maxi = radii(1, result);
%         name = 'yellow: individual shell';  
%     elseif isequal(visualisationType, 'all')
%         individual_min = radii(2, result);
%         individual_max = radii(1, result);
%         average_min = average(1);
%         average_max = average(2);
%         mean_min = mean(1);
%         mean_max = mean(2);
%         name = 'Comparison of all shell methods. Yellow: Landmark shell';    
%     end
%     
%     % get landmark coordinates in shell
%     if isequal(visualisationType, 'all')
%     landmarkInShell_mean = landmarkCoords';
%     normOfCoordinates_mean = normOfCoordinates;
%     landmarkInShell_mean(:,normOfCoordinates_mean < mean_min) = [];
%     normOfCoordinates_mean(:,normOfCoordinates_mean < mean_min) = [];
%     landmarkInShell_mean(:,normOfCoordinates_mean > mean_max) = [];
%     normOfCoordinates_mean(:,normOfCoordinates_mean > mean_max) = [];
%     landmarkInShell_mean = landmarkInShell_mean';
%     
%     landmarkInShell_average = landmarkCoords';
%     normOfCoordinates_average = normOfCoordinates;
%     landmarkInShell_average(:,normOfCoordinates_average < average_min) = [];
%     normOfCoordinates_average(:,normOfCoordinates_average < average_min) = [];
%     landmarkInShell_average(:,normOfCoordinates_average > average_max) = [];
%     normOfCoordinates_average(:,normOfCoordinates_average > average_max) = [];
%     landmarkInShell_average = landmarkInShell_average';
%     
%     landmarkInShell_individual = landmarkCoords';
%     normOfCoordinates_individual = normOfCoordinates;
%     landmarkInShell_individual(:,normOfCoordinates_individual < individual_min) = [];
%     normOfCoordinates_individual(:,normOfCoordinates_individual < individual_min) = [];
%     landmarkInShell_individual(:,normOfCoordinates_individual > individual_max) = [];
%     normOfCoordinates_individual(:,normOfCoordinates_individual > individual_max) = [];
%     landmarkInShell_individual = landmarkInShell_individual';
%     else   
%     landmarkInShell = landmarkCoords';   
%     landmarkInShell(:,normOfCoordinates < mini) = [];
%     normOfCoordinates(:,normOfCoordinates < mini) = [];
%     landmarkInShell(:,normOfCoordinates > maxi) = [];
%     normOfCoordinates(:,normOfCoordinates > maxi) = [];
%     landmarkInShell = landmarkInShell';
%     end
%     
%     % draw figure
%     if isequal(visualisationType, 'all')
%     %figure('Name', name);    
%     figure('Name', name,'units','normalized', 'outerposition',[0.1 0.1 0.9 0.4]); 
%     subplot(1,3,1);
%         scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
%         hold on
%         scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
%         hold on
%         scatter3(landmarkInShell_individual(:,1),landmarkInShell_individual(:,2),landmarkInShell_individual(:,3), 100,'*');
%         view(0,180);
%         %view(0,90);
%         title('individual')
%     subplot(1,3,2);
%         scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
%         hold on
%         scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
%         hold on
%         scatter3(landmarkInShell_mean(:,1),landmarkInShell_mean(:,2),landmarkInShell_mean(:,3), 100,'*');
%         view(0,180);
%         %view(0,90);
%         title('mean')
%     subplot(1,3,3);
%         scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
%         hold on
%         scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
%         hold on
%         scatter3(landmarkInShell_average(:,1),landmarkInShell_average(:,2),landmarkInShell_average(:,3), 100,'*');
%         view(0,180);
%         %view(0,90);
%         title('average')
%     else
%     figure('Name', name); scatter3(sphereCoordinates(:,1),sphereCoordinates(:,2),sphereCoordinates(:,3), 1,'*');
%     hold on
%     scatter3(landmarkCoords(:,1),landmarkCoords(:,2),landmarkCoords(:,3), 100,'*');
%     hold on
%     scatter3(landmarkInShell(:,1),landmarkInShell(:,2),landmarkInShell(:,3), 100,'*');
%     view(0,180);
%     %view(0,90);
%     drawnow;
%     end
% end    
% end    
    

end