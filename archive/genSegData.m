function [SegmentedData] = genSegData(Xs,Ys,Zs,Xc,Yc,Zc,datanames,resolution,scale)
%%GENSEGDATA: Generate Segmentation Data
%% Input:
%   Xs,Ys,Zs:   Meshgrid for the samples unit sphere
%   Xc,Yc,Zc:   Meshgrid for the samples unit cube
%   datanames:  Cell array with the names of the .mat files
%   resolution: Resolution of data
%   scale:      Scaling of the data

%% Output: 
%   SegmentedData: Data structure
%       TODO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code

% Generate a struct that stores all the different segmentation data.
SegmentedData = struct;
for i=1:size(datanames,1)
    fprintf(['Dataset ',num2str(i),' of ',num2str(size(datanames,1)),':\n']);
    % Load dataset
    fileName = char(datanames(i));
    fprintf(['File name: ', fileName,'\n']);
    load(fileName);
    % Compute the segmentaion of landmark and cells
    fprintf('Starting segmentation ...\n');
    output = LACSfun(data,resolution,scale);
    fprintf('Segmentation Done!\n');
    
    % Compute the transformed sphere and cube
    output.tSphere = struct;
    output.tCube = struct;
    
    % Transform unit sphere...
    scale_matrix = diag(1./output.ellipsoid.radii);
    rotation_matrix = output.ellipsoid.axes';
    [output.tSphere.Xs_t,output.tSphere.Ys_t,output.tSphere.Zs_t] ...
        = transformUnitSphere3D(Xs,Ys,Zs,scale_matrix,rotation_matrix,output.ellipsoid.center);
    
    % ... and cube
    [output.tCube.Xc_t,output.tCube.Yc_t,output.tCube.Zc_t] ...
        = transformUnitCube3D(Xc,Yc,Zc,scale_matrix,rotation_matrix,output.ellipsoid.center);
    fieldName = ['Data_',fileName(1:end-4)];
    
    % Projection: %
    fprintf('Starting projection onto the unit sphere and unit cube...');
    % Sample original space
    mind = [0 0 0]; maxd = size(output.landmark) .* resolution;
    %Create meshgrid with same resolution as data
    [ X, Y, Z ] = meshgrid( linspace( mind(2), maxd(2), size(output.landmark,2) ),...
        linspace( mind(1), maxd(1), size(output.landmark,1) ),...
        linspace( mind(3), maxd(3), size(output.landmark,3) ) );
    
    % Project segmented landmark onto unit sphere...
    output.GFPOnSphere ...
        = interp3(X, Y, Z, output.landmark, output.tSphere.Xs_t, output.tSphere.Ys_t, output.tSphere.Zs_t,'nearest');
    
    % ... and cells into unit cube
    CellsInSphere ...
        = interp3(X, Y, Z, output.cells, output.tCube.Xc_t, output.tCube.Yc_t, output.tCube.Zc_t,'nearest');
    CellsInSphere(isnan(CellsInSphere)) = 0;
    output.CellsInSphere = CellsInSphere;
    fprintf('Done!');
    
    % Save in structure
    SegmentedData.(fieldName) = output;
end

fprintf(['\n','Finished segmentation!']);

end

