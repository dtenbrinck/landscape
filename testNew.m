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

regressionLine2 = regressionLine;

figure(1), title('Regression line through the data set.');
scatter3(pstar(1),pstar(2),pstar(3));
hold on
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

%% Rotate characteristic points onto each other. 

pAngle = acos(pstar'*refpstar);

% pAngle rotates the vectors around the origin pstar cross refpstar
origin = cross(pstar,refpstar);

Rp =  SegmentationData.('Data_11').Rp;
vstarRP = Rp*vstar;
pstarRP = Rp*pstar;
G = geodesicFun(pstarRP,vstarRP);
regressionLineRP = G(T);


dataRotRP = Rp*regData_old;

figure(2),

hold on
xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
plot3(regressionLineRP(1,:),regressionLineRP(2,:),regressionLineRP(3,:));
scatter3(dataRotNew(1,:),dataRotNew(2,:),dataRotNew(3,:),'o')
scatter3(regData_ref(1,:),regData_ref(2,:),regData_ref(3,:),'x')
scatter3(dataRotRP(1,:),dataRotRP(2,:),dataRotRP(3,:),'*')
hold off