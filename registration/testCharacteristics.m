% normal position
regData = handles.SegData.Data_1.regData;
p = handles.SegData.Data_1.pstar;
v = handles.SegData.Data_1.vstar;

T = 0:0.01:2*pi;
G = geodesicFun(p,v);
regressionLine = G(T);

figure(1),cla,title('Random'),
scatter3(regData(1,:),regData(2,:),regData(3,:)), hold on,
quiver3(p(1),p(2),p(3),v(1),v(2),v(3)),
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:)),
scatter3(p(1),p(2),p(3),'*');

% head position

[p2,v2,rL2] = getCharPos(p,v,regData,'head');
figure(2),cla,title('Head'),
scatter3(regData(1,:),regData(2,:),regData(3,:)), hold on,
quiver3(p2(1),p2(2),p2(3),v2(1),v2(2),v2(3)),
plot3(rL2(1,:),rL2(2,:),rL2(3,:)),
scatter3(p2(1),p2(2),p2(3),'*');

% tail position

[p2,v2,rL2] = getCharPos(p,v,regData,'tail');
figure(3),cla,title('Tail'),
scatter3(regData(1,:),regData(2,:),regData(3,:)), hold on,
quiver3(p2(1),p2(2),p2(3),v2(1),v2(2),v2(3)),
plot3(rL2(1,:),rL2(2,:),rL2(3,:)),
scatter3(p2(1),p2(2),p2(3),'*');


% middle position

[p2,v2,rL2] = getCharPos(p,v,regData,'middle');
figure(4),cla,title('Middle'),
scatter3(regData(1,:),regData(2,:),regData(3,:)), hold on,
quiver3(p2(1),p2(2),p2(3),v2(1),v2(2),v2(3)),
plot3(rL2(1,:),rL2(2,:),rL2(3,:)),
scatter3(p2(1),p2(2),p2(3),'*');


% weight position

[p2,v2,rL2] = getCharPos(p,v,regData,'weight');
figure(5),cla,title('Weight'),
scatter3(regData(1,:),regData(2,:),regData(3,:)), hold on,
quiver3(p2(1),p2(2),p2(3),v2(1),v2(2),v2(3)),
plot3(rL2(1,:),rL2(2,:),rL2(3,:)),
scatter3(p2(1),p2(2),p2(3),'*');

