p1 = handles.SegData.Data_1.pstar;
p2 = handles.SegData.Data_2.pstar;
p3 = handles.SegData.Data_3.pstar;
p4 = handles.SegData.Data_4.pstar;
p5 = handles.SegData.Data_5.pstar;
v1 = handles.SegData.Data_1.vstar;
v2 = handles.SegData.Data_2.vstar;
v3 = handles.SegData.Data_3.vstar;
v4 = handles.SegData.Data_4.vstar;
v5 = handles.SegData.Data_5.vstar;
regData1 = handles.SegData.Data_1.regData;
regData2 = handles.SegData.Data_2.regData;
regData3 = handles.SegData.Data_3.regData;
regData4 = handles.SegData.Data_4.regData;
regData5 = handles.SegData.Data_5.regData;

% Data 1

figure(1),cla,hold on,
scatter3(regData1(1,:),regData1(2,:),regData1(3,:)),
scatter3(p1(1),p1(2),p1(3),'*'),

% Data 2

figure(2),cla,hold on,
scatter3(regData2(1,:),regData2(2,:),regData2(3,:)),
scatter3(p2(1),p2(2),p2(3),'*'),

% Data 3

figure(3),cla,hold on,
scatter3(regData3(1,:),regData3(2,:),regData3(3,:)),
scatter3(p3(1),p3(2),p3(3),'*'),

% Data 4

figure(4),cla,hold on,
scatter3(regData4(1,:),regData4(2,:),regData4(3,:)),
scatter3(p4(1),p4(2),p4(3),'*'),

% Data 5

figure(5),cla,hold on,
scatter3(regData5(1,:),regData5(2,:),regData5(3,:)),
scatter3(p5(1),p5(2),p5(3),'*'),
