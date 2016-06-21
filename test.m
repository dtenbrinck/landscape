%% show old data in one plot
close all;

pstar =  SegmentationData.('Data_11').pstar;
vstar =  SegmentationData.('Data_11').vstar;
regData_ref = SegmentationData.('Data_1').regData;
regData_old = SegmentationData.('Data_11').regData;
T = 0:0.01:10;
G = geodesicFun(pstar,vstar);
regressionLine = G(T);
F = geodesicFun(refpstar,refvstar);
refRegressionLine = F(T);
POINT = regData_old(:,30);
regressionLine2 = regressionLine;

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
scatter3(regData_old(1,:),regData_old(2,:),regData_old(3,:),'o')
scatter3(regData_ref(1,:),regData_ref(2,:),regData_ref(3,:),'*')
hold off

%% rotate it
Rp =  SegmentationData.('Data_11').Rp;
Rv =  SegmentationData.('Data_11').Rv;
pstar_r =  SegmentationData.('Data_11').pstar_r;
vstar_r =  SegmentationData.('Data_11').vstar_r;
vAngle =  SegmentationData.('Data_11').vAngle;
regData_r = Rp*regData_old;
vstar = Rp*vstar;
POINT = Rp*POINT;
G = geodesicFun(pstar_r,vstar);
regressionLine2 = Rp*regressionLine2;
regressionLine = G(T);

figure(2), title('Regression line through the data set.');
scatter3(pstar_r(1),pstar_r(2),pstar_r(3));
hold on
scatter3(POINT(1),POINT(2),POINT(3),'x');
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

Rxz = compRxz(refpstar);
Rz = compRz(refpstar);
R = genAngleRotZ(-vAngle);

% Rotate refpstar onto z axis

% Rotate data around z axis 

% Inverse to xz plane

% Inverse onto refpstar

dataRotated = Rxz^-1*Rz^-1*R*Rz*Rxz*regData_r;

matrix = [0,-refpstar(3),refpstar(2);refpstar(3), 0, -refpstar(1); -refpstar(2),refpstar(1),0];
matrix2 = [refpstar(1)^2,refpstar(1)*refpstar(2),refpstar(1)*refpstar(3);...
    refpstar(1)*refpstar(2),refpstar(2)^2,refpstar(2)*refpstar(3);...
    refpstar(1)*refpstar(3),refpstar(2)*refpstar(3),refpstar(3)^2];
RR = cos(-vAngle)*eye(3)+sin(-vAngle)*matrix+(1-cos(-vAngle))*matrix2;
dataRotatedRR = RR*regData_r;
%regressionLine2 = Rxz^-1*Rz^-1*R*Rz*Rxz*Rp*regressionLine2;
vstar = Rv*Rp*vstar;

G = geodesicFun(pstar_r,vstar);
regressionLine = G(T);
dataRR = regData
figure(3), title('Regression line through the data set.');
scatter3(pstar_r(1),pstar_r(2),pstar_r(3));
hold on
scatter3(refpstar(1),refpstar(2),refpstar(3));
quiver3(pstar_r(1),pstar_r(2),pstar_r(3),vstar(1)/norm(vstar),vstar(2)/norm(vstar),vstar(3)/norm(vstar));
quiver3(refpstar(1),refpstar(2),refpstar(3),refvstar(1)/norm(refvstar),refvstar(2)/norm(refvstar),refvstar(3)/norm(refvstar));
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
%plot3(regressionLine2(1,:),regressionLine2(2,:),regressionLine2(3,:),'g');
plot3(refRegressionLine(1,:),refRegressionLine(2,:),refRegressionLine(3,:),'r');
%plot3(data(1,1),data(2,1),data(3,1),'o')
%plot3(data(1,end),data(2,end),data(3,end),'o')
xlim([-1.1,1.1]);
ylim([-1.1,1.1]);
zlim([-1.1,1.1]);
%plot3(x,y,z);
%scatter3(dataRotated(1,:),dataRotated(2,:),dataRotated(3,:),'o')
scatter3(dataRotatedRR(1,:),dataRotatedRR(2,:),dataRotatedRR(3,:),'o')
scatter3(regData_ref(1,:),regData_ref(2,:),regData_ref(3,:),'*')
hold off


sphericalRegression3D(dataRotatedRR,pstar_r,vstar);