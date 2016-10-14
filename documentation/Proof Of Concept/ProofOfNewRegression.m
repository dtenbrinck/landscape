lC = landmarkCoordinates;
lC_trunc = lC;
lC_trunc(find(lC_trunc(:,3)>0),:) = [];
[pstar_old,vstar_old] = computeRegression(lC','true');
[pstar_new,vstar_new,Tstar] = computeRegression_new(lC','true');
[pstar_old_trunc,vstar_old_trunc] = computeRegression(lC_trunc','true');
[pstar_new_trunc,vstar_new_trunc,Tstar_trunc] = computeRegression_new(lC_trunc','true');

G_old = geodesicFun(pstar_old,vstar_old);
G_new = geodesicFun(pstar_new,vstar_new);
T = 0:1/10:2*pi;
rL_old = G_old(T);
rL_new = G_new(T);
G_old_trunc = geodesicFun(pstar_old_trunc,vstar_old_trunc);
G_new_tunc = geodesicFun(pstar_new_trunc,vstar_new_trunc);
T = 0:1/10:2*pi;
rL_old_trunc = G_old_trunc(T);
rL_new_trunc = G_new_tunc(T);


figure,
subplot(2,2,1),hold on,axis equal,title('Old Algorithm');
xlim([-1,1])
ylim([-1,1])
zlim([-1,1])
scatter3(lC(:,1),...
    lC(:,2),...
    lC(:,3)),
plot3(rL_old(1,:),rL_old(2,:),rL_old(3,:));
subplot(2,2,2),hold on,axis equal,title('New algorithm')
xlim([-1,1])
ylim([-1,1])
zlim([-1,1])
scatter3(lC(:,1),...
    lC(:,2),...
    lC(:,3)),
plot3(rL_new(1,:),rL_new(2,:),rL_new(3,:));

subplot(2,2,3),hold on,axis equal,title('Old Algorithm trunceted shape');
xlim([-1,1])
ylim([-1,1])
zlim([-1,1])
scatter3(lC_trunc(:,1),...
    lC_trunc(:,2),...
    lC_trunc(:,3)),
plot3(rL_old_trunc(1,:),rL_old_trunc(2,:),rL_old_trunc(3,:));
subplot(2,2,4),hold on,axis equal,title('New algorithm truncated shape')
xlim([-1,1])
ylim([-1,1])
zlim([-1,1])
scatter3(lC_trunc(:,1),...
    lC_trunc(:,2),...
    lC_trunc(:,3)),
plot3(rL_new_trunc(1,:),rL_new_trunc(2,:),rL_new_trunc(3,:));


