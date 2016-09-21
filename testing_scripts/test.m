cells1 = handles.SegData.Data_1.cells;
cells2 = handles.SegData.Data_2.cells;
cells3 = handles.SegData.Data_3.cells;
cells4 = handles.SegData.Data_4.cells;
cells5 = handles.SegData.Data_5.cells;
% cells1 = imresize(cells1,1/0.75);
% cells2 = imresize(cells2,1/0.75);
% cells3 = imresize(cells3,1/0.75);
% cells4 = imresize(cells4,1/0.75);
% cells5 = imresize(cells5,1/0.75);
% cells1(cells1>0) = 1;
% cells2(cells2>0) = 1;
% cells3(cells3>0) = 1;
% cells4(cells4>0) = 1;
% cells5(cells5>0) = 1;
mCherry1 = handles.data.Data_1.mCherry;
mCherry2 = handles.data.Data_2.mCherry;
mCherry3 = handles.data.Data_3.mCherry;
mCherry4 = handles.data.Data_4.mCherry;
mCherry5 = handles.data.Data_5.mCherry;
occ1 = handles.SegData.Data_1.origCentCoords;
occ2 = handles.SegData.Data_2.origCentCoords;
occ3 = handles.SegData.Data_3.origCentCoords;
occ4 = handles.SegData.Data_4.origCentCoords;
occ5 = handles.SegData.Data_5.origCentCoords;
mCherry1(sub2ind(size(mCherry1),occ1(2,:),occ1(1,:),occ1(3,:))) = -2000;
mCherry2(sub2ind(size(mCherry2),occ2(2,:),occ2(1,:),occ2(3,:))) = -2000;
mCherry3(sub2ind(size(mCherry3),occ3(2,:),occ3(1,:),occ3(3,:))) = -2000;
mCherry4(sub2ind(size(mCherry4),occ4(2,:),occ4(1,:),occ4(3,:))) = -2000;
mCherry5(sub2ind(size(mCherry5),occ5(2,:),occ5(1,:),occ5(3,:))) = -2000;

for i=1:20
    figure(1),cla,imagesc(mCherry1(:,:,i)),hold on;
    figure(2),cla,imagesc(mCherry2(:,:,i)),hold on;
    figure(3),cla,imagesc(mCherry3(:,:,i)),hold on;
    figure(4),cla,imagesc(mCherry4(:,:,i)),hold on;
    figure(5),cla,imagesc(mCherry5(:,:,i)),hold on;
    pause();
end
%%
centCoords = output.centCoords;
cells = output.cells;
oc = output.origCentCoords;
[x,y,z] = sphere;
figure,scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:)),hold on,
plot3(x,y,z),xlim([-1,1]),
ylim([-1,1]),zlim([-1,1]);
cellpoints = zeros(size(cells));
cellpoints(sub2ind(size(cells),oc(2,:),oc(1,:),oc(3,:)))=1;
figure,imagesc(sum(cellpoints,3));
cells3 = cells+cellpoints;
figure,imagesc(sum(cells3,3)),set(gca,'Ydir','normal');
GFPOnSphere = output.GFPOnSphere;
% RegData
regData = [(round(Xs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Ys(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Zs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
% Delete all multiple points
regData = unique(regData','rows')';
figure,scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:),'*'),hold on,
plot3(x,y,z),xlim([-1,1]),
scatter3(regData(1,:),regData(2,:),regData(3,:)),
ylim([-1,1]),zlim([-1,1]);
figure,imagesc(max(output.landmark,[],3)+2*sum(cellpoints,3));set(gca,'Ydir','normal');
%%
oc = origCentCoords;
cells2 = cells;
cells2(sub2ind(size(cells),oc(2,:),oc(1,:),oc(3,:))) = 2;
for i=1:20
    figure(1),cla,imagesc(cells2(:,:,i))
    pause(1)
end