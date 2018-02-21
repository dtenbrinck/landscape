function flow = computeOF( Dapi_data )
% calculates velocity field for background flow in Dapi-channel

addpath(genpath('../tracking/motionEstimationGUI'));

flow  = zeros(size(Dapi_data,1),size(Dapi_data,2),size(Dapi_data,3),size(Dapi_data,4),3);
scale = 1/4; % scaling factor in x and y direction for speeding up

for step=1:size(Dapi_data,4)-1; % number of timesteps
 
    YFP1tmp = zeros(size(Dapi_data,1),size(Dapi_data,2),size(Dapi_data,3)); 
    YFP2tmp = zeros(size(YFP1tmp));
    YFP1=zeros(size(YFP1tmp,1)*scale,size(YFP1tmp,2)*scale,31);  % scaled size
    YFP2=zeros(size(YFP1));
    
    %% pick and scale subsequent time steps
    for i=1:size(Dapi_data,3) % number of z-slices
        YFP1tmp(:,:,i+1)=Dapi_data(:,:,i,step);
        YFP1(:,:,i+1)=imresize(YFP1tmp(:,:,i+1),scale,'cubic');
        YFP2tmp(:,:,i+1)=Dapi_data(:,:,i,step+1);
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
            flow(:,:,i,step,j)=imresize(v(:,:,i,1,j),1/scale,'cubic');
            % visualize flow in single directions slide by slide in x-y
%             fig(1);imagesc(flow(:,:,i,1,j));axis image;title(['Field ',num2str(i),', component ',num2str(j)]);colorbar;pause
        end
    end
    
end

end