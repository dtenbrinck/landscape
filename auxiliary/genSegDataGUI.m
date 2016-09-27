function [SegmentedData] = genSegDataGUI(bigdata,samples,resolution)
%%GENSEGDATA: Generate Segmentation Data in the GUI framework.
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
datanames = fieldnames(bigdata);
% Create waitbar
wb1=waitbar(0, 'Segmentation...');
set(findobj(wb1,'type','patch'),'edgecolor','k','facecolor','b');
for i=1:size(datanames,1)
    fprintf(['Dataset ',num2str(i),' of ',num2str(size(datanames,1)),':\n']);
    
    % --- Load dataset --- %
    fileName = char(datanames(i));

    fprintf(['File name: ', fileName,'\n']);
    data = bigdata.(char(datanames(i)));
    
    % --- Preprocess the data --- %
    fprintf('Preprocess the data...');
    data = preprocessData(data);
    fprintf('Done!\n');
    
    % --- Segmentaion of landmark and cells --- %
    fprintf('Starting segmentation ...');
    output = LACSfun(data,resolution);
    fprintf('Done!\n');
    
    % --- Projection --- %
    fprintf('Starting projection...\n');
    output = ProjectionOnSphere(output,samples,resolution);
    fprintf('Projection done!\n');
    
    % Save in structure
    SegmentedData.(fileName) = output;
    
    % Update waitbar
    waitbar(i/size(datanames,1));
    fprintf('--------------------------------------------------');
    drawnow;
end

% Close waitbar
close(wb1);

fprintf(['\n','Finished segmentation!\n']);

end

