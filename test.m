%% show old data in one plot
close all;

pstar =  SegmentationData.('Data_12').pstar;
vstar =  SegmentationData.('Data_12').vstar;
cells =  SegmentationData.('Data_12').centCoords;
regData_ref = SegmentationData.('Data_1').regData;
regData_old = SegmentationData.('Data_12').regData;
T = 0:0.01:10;
G = geodesicFun(pstar,vstar);
regressionLine = G(T);
F = geodesicFun(refpstar,refvstar);
refRegressionLine = F(T);
POINT = regData_old(:,30);
regressionLine2 = regressionLine;

[x,y,z] = sphere;

figure(1), title('Regression line through the data set.');
scatter3(pstar(1),pstar(2),pstar(3));
hold on
scatter3(POINT(1),POINT(2),POINT(3),'x');
scatter3(refpstar(1),refpstar(2),refpstar(3));
quiver3(pstar(1),pstar(2),pstar(3),vstar(1)/norm(vstar),vstar(2)/norm(vstar),vstar(3)/norm(vstar));
quiver3(refpstar(1),refpstar(2),refpstar(3),refvstar(1)/norm(refvstar),refvstar(2)/norm(refvstar),refvstar(3)/norm(refvstar));
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
plot3(refRegressionLine(1,:),refRegressionLine(2,:),refRegressionLine(3,:),'r');
%plot3(data(1,1),data(2,1),data(3,1),'o')
%plot3(data(1,end),data(2,end),data(3,end),'o')
xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
%plot3(x,y,z);
scatter3(cells(1,:),cells(2,:),cells(3,:),'x')
scatter3(regData_old(1,:),regData_old(2,:),regData_old(3,:),'o')
scatter3(regData_ref(1,:),regData_ref(2,:),regData_ref(3,:),'*')
hold off

%% rotate it
Rp =  SegmentationData.('Data_12').Rp;
Rv =  SegmentationData.('Data_12').Rv;
pstar_r =  SegmentationData.('Data_12').pstar_r;
vstar_r =  SegmentationData.('Data_12').vstar_r;
vAngle =  SegmentationData.('Data_12').vAngle;
regData_r = Rp*regData_old;
cells_r = Rp*cells;
vstar = Rp*vstar;
POINT = Rp*POINT;
G = geodesicFun(pstar_r,vstar);
regressionLine2 = Rp*regressionLine2;
regressionLine = G(T);

figure(2), title('Regression line through the data set.');
scatter3(pstar_r(1),pstar_r(2),pstar_r(3));
hold on
scatter3(cells_r(1),cells_r(2),cells_r(3),'x');
scatter3(refpstar(1),refpstar(2),refpstar(3));
quiver3(pstar_r(1),pstar_r(2),pstar_r(3),vstar(1)/norm(vstar),vstar(2)/norm(vstar),vstar(3)/norm(vstar));
quiver3(refpstar(1),refpstar(2),refpstar(3),refvstar(1)/norm(refvstar),refvstar(2)/norm(refvstar),refvstar(3)/norm(refvstar));
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
plot3(regressionLine2(1,:),regressionLine2(2,:),regressionLine2(3,:),'g');
plot3(refRegressionLine(1,:),refRegressionLine(2,:),refRegressionLine(3,:),'r');
%plot3(data(1,1),data(2,1),data(3,1),'o')
%plot3(data(1,end),data(2,end),data(3,end),'o')
xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
%plot3(x,y,z);
scatter3(regData_r(1,:),regData_r(2,:),regData_r(3,:),'o')
scatter3(regData_ref(1,:),regData_ref(2,:),regData_ref(3,:),'*')
hold off
sphericalRegression3D(regData_r,pstar_r,vstar);

%%
% Rotation of data around axis refpstar
% Rotate refpstar onto xz plane



% Rotate refpstar onto z axis

% Rotate data around z axis 

% Inverse to xz plane

% Inverse onto refpstar


matrix = [0,-refpstar(3),refpstar(2);refpstar(3), 0, -refpstar(1); -refpstar(2),refpstar(1),0];
matrix2 = [refpstar(1)^2,refpstar(1)*refpstar(2),refpstar(1)*refpstar(3);...
    refpstar(1)*refpstar(2),refpstar(2)^2,refpstar(2)*refpstar(3);...
    refpstar(1)*refpstar(3),refpstar(2)*refpstar(3),refpstar(3)^2];
RR = cos(-vAngle)*eye(3)+sin(-vAngle)*matrix+(1-cos(-vAngle))*matrix2;
RR2 = rotAboutAxis(-vAngle,refpstar);
dataRotatedRR = RR2*regData_r;
cellsRR = RR2*cells_r;
%regressionLine2 = Rxz^-1*Rz^-1*R*Rz*Rxz*Rp*regressionLine2;
vstar = Rv*vstar;
regressionLine2 = RR2*regressionLine2;
G = geodesicFun(pstar_r,vstar);
regressionLine = G(T);


figure(3), title('Regression line through the data set.');
scatter3(pstar_r(1),pstar_r(2),pstar_r(3));
hold on
scatter3(refpstar(1),refpstar(2),refpstar(3));
quiver3(pstar_r(1),pstar_r(2),pstar_r(3),vstar(1)/norm(vstar),vstar(2)/norm(vstar),vstar(3)/norm(vstar));
quiver3(refpstar(1),refpstar(2),refpstar(3),refvstar(1)/norm(refvstar),refvstar(2)/norm(refvstar),refvstar(3)/norm(refvstar));
%plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
plot3(regressionLine2(1,:),regressionLine2(2,:),regressionLine2(3,:),'g');
%plot3(refRegressionLine(1,:),refRegressionLine(2,:),refRegressionLine(3,:),'r');
%plot3(data(1,1),data(2,1),data(3,1),'o')
%plot3(data(1,end),data(2,end),data(3,end),'o')
xlim([-1.1,1.1]);
ylim([-1.1,1.1]);
zlim([-1.1,1.1]);
%plot3(x,y,z);
scatter3(cellsRR(1,:),cellsRR(2,:),cellsRR(3,:),'x')
scatter3(dataRotatedRR(1,:),dataRotatedRR(2,:),dataRotatedRR(3,:),'o')
scatter3(regData_ref(1,:),regData_ref(2,:),regData_ref(3,:),'*')
hold off


sphericalRegression3D(dataRotatedRR,pstar_r,vstar);