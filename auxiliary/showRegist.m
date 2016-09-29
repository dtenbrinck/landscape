function [] = showRegist(rS, S, rFieldName, FieldName)
%SHOWREGIST:    This function visualizes the registration data.
%% Input:
%   rS:         SegmentationData structure of reference data set.
%   S:          SegmentationData structure of the registered data set.
%   rFieldName: Fieldname of the reference dataset.
%   FieldName:  Fieldname of the registered data set.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Main Code:

% Setting up the regression line
T = 0:0.01:100;
G = geodesicFun(rS.pstar,rS.vstar);
regressionLine = G(T);

% Visualize
figure, 
plot3(regressionLine(1,:),regressionLine(2,:),regressionLine(3,:),'r');
hold on;
scatter3(rS.regData(1,:),rS.regData(2,:),rS.regData(3,:), 'o');
scatter3(S.regData_r(1,:),S.regData_r(2,:),S.regData_r(3,:), 'x');
scatter3(S.centCoords(1,:),S.centCoords(2,:),S.centCoords(3,:), '*');
xlim([-1,1]);
ylim([-1,1]);
zlim([-1,1]);
grid on;
title(['Registered data of ',FieldName,' onto ', rFieldName], 'Interpreter', 'none');
legend({'Regression Line',rFieldName,FieldName},'Interpreter','none');
end