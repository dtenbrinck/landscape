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

%% CHECK FLIPPING 
lmrot = output.landmark;
lm = rot90(lmrot,2);
centCoords = output.centCoords;
regData = output.regData;

figure,imagesc(max(lm,[],3)),title('No rotation'), hold on,
figure,imagesc(max(lmrot,[],3)),title('Rotation'), hold on,

figure,scatter3(regData(1,:),regData(2,:),regData(3,:)),hold on,
scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:)),
xlim([-1,1]),title('No Rotation');
ylim([-1,1]),zlim([-1,1]);
figure,scatter3(-regData(1,:),-regData(2,:),regData(3,:)), hold on,
scatter3(-centCoords(1,:),-centCoords(2,:),centCoords(3,:)),
xlim([-1,1]),title('Rotation'),
ylim([-1,1]),zlim([-1,1]);

%% WHY ARE THE OTHER REGDATAS WRONG?
regData1 = handles.SegData.Data_1.regData;
regData2 = handles.SegData.Data_2.regData;
regData3 = handles.SegData.Data_3.regData;
regData4 = handles.SegData.Data_4.regData;
regData5 = handles.SegData.Data_5.regData;

figure,scatter3(regData1(1,:),regData1(2,:),regData1(3,:)), hold on,
xlim([-1,1]),
ylim([-1,1]),zlim([-1,1]);
figure,imagesc(max(handles.SegData.Data_1.landmark,[],3));


figure,scatter3(regData2(1,:),regData2(2,:),regData2(3,:)), hold on,
xlim([-1,1]),
ylim([-1,1]),zlim([-1,1]);
figure,imagesc(max(handles.SegData.Data_2.landmark,[],3));


figure,scatter3(regData3(1,:),regData3(2,:),regData3(3,:)), hold on,
xlim([-1,1]),
ylim([-1,1]),zlim([-1,1]);
figure,imagesc(max(handles.SegData.Data_3.landmark,[],3));

figure,scatter3(regData4(1,:),regData4(2,:),regData4(3,:)), hold on,
xlim([-1,1]),
ylim([-1,1]),zlim([-1,1]);
figure,imagesc(max(handles.SegData.Data_4.landmark,[],3));

figure,scatter3(regData5(1,:),regData5(2,:),regData5(3,:)), hold on,
xlim([-1,1]),
ylim([-1,1]),zlim([-1,1]);
figure,imagesc(max(handles.SegData.Data_5.landmark,[],3));

A = handles.SegData.Data_1.ellipsoid.axes;
figure,quiver3([0,0,0],[0,0,0],[0,0,0],A(1,:),A(2,:),A(3,:));
A = handles.SegData.Data_2.ellipsoid.axes;
figure,quiver3([0,0,0],[0,0,0],[0,0,0],A(1,:),A(2,:),A(3,:));
A = handles.SegData.Data_3.ellipsoid.axes;
figure,quiver3([0,0,0],[0,0,0],[0,0,0],A(1,:),A(2,:),A(3,:));
A = handles.SegData.Data_4.ellipsoid.axes;
figure,quiver3([0,0,0],[0,0,0],[0,0,0],A(1,:),A(2,:),A(3,:));
A = handles.SegData.Data_5.ellipsoid.axes;
figure,quiver3([0,0,0],[0,0,0],[0,0,0],A(1,:),A(2,:),A(3,:));

%% ROTATING THE CELLS CORRECTLY?
regData1 = handles.SegData.Data_1.regData;
regData2 = handles.SegData.Data_2.regData;
regData3 = handles.SegData.Data_3.regData;
regData4 = handles.SegData.Data_4.regData;
regData5 = handles.SegData.Data_5.regData;
% show reference
pref = handles.SegData.Data_1.pstar;
vref = handles.SegData.Data_1.vstar;
figure,scatter3(regData1(1,:),regData1(2,:),regData1(3,:)), hold on,
xlim([-1,1]),ylim([-1,1]),zlim([-1,1]),title('Reference');
% show the other before and after rotation.
p = handles.SegData.Data_3.pstar;
v = handles.SegData.Data_3.vstar;
Rp = handles.SegData.Data_3.Rp;
Ra = handles.SegData.Data_3.Ra;
Rv = handles.SegData.Data_3.Rv;
centCoords = handles.SegData.Data_3.centCoords;
f = figure;
scatter3(regData3(1,:),regData3(2,:),regData3(3,:)),hold on,
scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:),'x','m')
xlim([-1,1]),ylim([-1,1]),zlim([-1,1]),title('Embryo');
pause(1);
title('Drawing regression line.');
T = 0:0.01:2*pi;
G = geodesicFun(p,v);
rL3 = G(T);
plot3(rL3(1,:),rL3(2,:),rL3(3,:))
pause(1);
title('Getting head coordinate.')
scatter3(p(1),p(2),p(3),'*','r');
pause(1);
title('Show reference embryo');
scatter3(regData1(1,:),regData1(2,:),regData1(3,:),'x','g')
pause(1);
title('Drawing regression line.');
G = geodesicFun(pref,vref);
regressionLine2 = G(T);
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'g')
pause(1);
title('Getting head coordinate.')
scatter3(pref(1),pref(2),pref(3),'g','*');
pause(1),cla,
title('Rotating p onto the reference')
regData3_r = Rp*regData3;
scatter3(regData3_r(1,:),regData3_r(2,:),regData3_r(3,:),'r');
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'g')
scatter3(pref(1),pref(2),pref(3),'g','*');
scatter3(regData1(1,:),regData1(2,:),regData1(3,:),'x','g')
p = Rp*p;
v = Rv*v;
centCoords = Rp*centCoords;
scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:),'x','m')
scatter3(p(1),p(2),p(3),'*','r');
rL3 = Rp*rL3;
plot3(rL3(1,:),rL3(2,:),rL3(3,:));
pause(1),cla,
title('Rotating regression line onto reference')
regData3_r = Ra*regData3_r;
scatter3(regData3_r(1,:),regData3_r(2,:),regData3_r(3,:),'r');
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'g')
scatter3(pref(1),pref(2),pref(3),'g','*');
scatter3(regData1(1,:),regData1(2,:),regData1(3,:),'x','g')
p = Ra*p;
centCoords = Ra*centCoords;
scatter3(centCoords(1,:),centCoords(2,:),centCoords(3,:),'x','m')
scatter3(p(1),p(2),p(3),'*','r');
rL3 = Ra*rL3;
plot3(rL3(1,:),rL3(2,:),rL3(3,:));

%% Show that the transformed cells really make the correct heatmap.
% And are really turned in the correct way

dM = h.densMat;
figure,imagesc(sum(dM,3))

% Get the regresion data
regData3 = h.MGH.SegData.Data_2.regData_r;
cC = h.MGH.SegData.Data_2.centCoords;
figure,scatter3(regData3(1,:),regData3(2,:),regData3(3,:)), hold on,
xlim([-1,1]),ylim([-1,1]),zlim([-1,1]),
scatter3(cC(1,:),cC(2,:),cC(3,:));

[samCoordsG,samCoordsU] ...
        = fitOnSamSphere(cC,h.MGH.samples);
[densMat,coordMat] ...
        = compDens3D(h.MGH.samples,samCoordsG,1,'sphere');
figure,imagesc(sum(densMat,3)),set(gca,'Ydir','normal');
%%
oc = origCentCoords;
cells2 = cells;
cells2(sub2ind(size(cells),oc(2,:),oc(1,:),oc(3,:))) = 2;
for i=1:20
    figure(1),cla,imagesc(cells2(:,:,i))
    pause(1)
end