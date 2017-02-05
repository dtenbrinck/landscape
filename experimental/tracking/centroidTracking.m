close all; clear all; clc

addpath(genpath(cd));

load('D:\Biologen\embryo_registration\10um_300s_mCherry');
% load('D:\Biologen\embryo_registration\15um_180s_mCherry');
% load('D:\Biologen\embryo_registration\20um_130s_mCherry');

cells=logical(segmentedCells);

centroid=zeros(50,2,size(cells,3));
M=size(cells,1);
N=size(cells,2);
d=2;
r=6;
[X,Y]=meshgrid(1:r:N,1:r:M);

 
for i=1:size(cells,3)
    props=regionprops(cells(:,:,i),'centroid');
    centroid(1:size(props,1),:,i) = cat(1, props.Centroid);
    
    figure(100);
    imshow(segmentedCells(:,:,i))
    hold on
    plot(centroid(:,1,i),centroid(:,2,i), 'r*')
    hold off
%     pause;

%     load(['results\nonlinear\TV\Zebrafish\alpha0.5\step', num2str(i),'.mat'])
%     vOrig=v;
%     firstflow=figure(5); imagesc(flowToColorV2(cat(3,v(:,:,1,1),v(:,:,1,2))));title('Estimated velocity field');
%     save_figure(fullfile(['firstflow', num2str(i), '.png']),firstflow,'png');
%     firstvector=figure(6);
%     imagesc(segmentedCells(:,:,i));  colormap gray;
%     hold on;
%     quiver(X,Y, v(1:r:M,1:r:N,1,1),v(1:r:M,1:r:N,1,2),2,'g','LineWidth',1.1);
%     hold off;
%     save_figure(fullfile(['firstvector', num2str(i), '.png']),firstvector,'png');
%     v(:,:,1,1)=vOrig(:,:,1,1)-mean(mean(v(:,:,1,1)));
%     v(:,:,1,2)=vOrig(:,:,1,2)-mean(mean(v(:,:,1,2)));
%     vSmall=(abs(v)<0.12);
%     v(vSmall)=0;
%     segment=figure(2); imagesc(segmentedCells(:,:,i)); colormap gray;
%     save_figure(fullfile(['segmentation', num2str(i), '.png']),segment,'png');
%     flow=figure(3); imagesc(flowToColorV2(cat(3,v(:,:,1,1),v(:,:,1,2))));title('Estimated velocity field');
%     save_figure(fullfile(['flow', num2str(i), '.png']),flow,'png');
%     vector=figure(4);
%     imagesc(segmentedCells(:,:,i));  colormap gray;
%     hold on;
%     quiver(X,Y, v(1:r:M,1:r:N,1,1),v(1:r:M,1:r:N,1,2),2,'g','LineWidth',1.1);
%     hold off;
%     save_figure(fullfile(['vector', num2str(i), '.png']),vector,'png');
%     pause;
end