function [] = showSbS(sbsMat)
%SHOWSBS: Shows a 3D matrix slice by slice in the 3rd dimension.
%% Input
% sbsMat:   3D matrix.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Code

siz = size(sbsMat);

f = figure;
colormap('jet');

for i=1:siz(3)
    imagesc(sbsMat(:,:,i));
    colorbar;
    caxis([0,max(sbsMat(:))]);
    pause();
end

