function flow = computeOF( experimentData.Dapi )
% calculates velocity field for background flow in Dapi-channel

addpath(genpath('../tracking/motionEstimationGUI'));

flow  = zeros(size(experimentData.Dapi,1),size(experimentData.Dapi,2),size(experimentData.Dapi,3),size(experimentData.Dapi,4),3);
scale = 1/8; % scaling factor in x and y direction for speeding up

for step=1:size(experimentData.Dapi,4); % number of timesteps
 
    YFP1tmp = zeros(size(experimentData.Dapi,1),size(experimentData.Dapi,2),size(experimentData.Dapi,3)); 
    YFP2tmp = zeros(size(YFP1tmp));
    YFP1=zeros(size(YFP1tmp,1)*scale,size(YFP1tmp,2)*scale,31);  % scaled size
    YFP2=zeros(size(YFP1));
    
    %% pick and scale subsequent time steps
    for i=0:size(experimentData.Dapi,3)-1 % number of z-slices
        YFP1tmp(:,:,i+1)=experimentData.Dapi(:,:,i,step);
        YFP1(:,:,i+1)=imresize(YFP1tmp(:,:,i+1),scale,'cubic');
        YFP2tmp(:,:,i+1)=experimentData.Dapi(:,:,i,step+1);
        YFP2(:,:,i+1)=imresize(YFP2tmp(:,:,i+1),scale,'cubic');
    end
    
    u = cat(4,YFP1,YFP2);
    dimsU = size(u);
    tol = 1e-5;

    %% Optical Flow for YFP

    alpha = 0.01;
    verbose = 0;
    dataTerm = 'L1';
    regularizerTerm = 'L2';
    doGradientConstancy = 0;
    steplength = 0.8;
    numberOfWarps = 5;

    motionEstimator = motionEstimatorClass(u,tol,alpha,'verbose',verbose,'dataTerm',dataTerm,'regularizerTerm',regularizerTerm,'doGradientConstancy',doGradientConstancy,'steplength',steplength,'numberOfWarps',numberOfWarps);
    motionEstimator.init;
    tic;motionEstimator.runPyramid;toc;
    v = motionEstimator.getResult;
       
    %% rescale flow to obtain original resolution
    for j=1:3
        for i=1:size(flow,3)
            flow(:,:,i)=imresize(v(:,:,i,step,j),1/scale,'cubic');
            % visualize flow in single directions slide by slide in x-y
%             fig(1);imagesc(flow(:,:,i,step,j));axis image;title(['Field ',num2str(i),', component ',num2str(j)]);colorbar;pause
        end
    end
    
end

end