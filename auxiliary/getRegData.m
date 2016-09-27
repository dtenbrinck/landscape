function [regData] = getRegData(GFPOnSphere,samples)
% GETREGDATA:   This function generates the regression data of the embryo.
% This will transform the gathered segmentation onto the sphere.
%% INPUT: %%
%   GFPOnSphere:    GFPOnSphere.
%   samples:        Samples to sample the space.
%% OUTPUT: %%
%   regData:        Points on the sphere that will give the shape of the
%                   embryo.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN CODE: %%

% Generate sampled sphere
[alpha, beta] = meshgrid(linspace(pi,2*pi,samples/2), linspace(0,2*pi,samples));
Zs = cos(alpha) .* sin(beta);
Xs = sin(alpha) .* sin(beta);
Ys = cos(beta);

% Compute regression data
regData = [(round(Xs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Ys(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)';...
        (round(Zs(GFPOnSphere == 1 & Zs <= 0)*10^10)/10^10)'];
    
% Delete all multiple points
regData = unique(regData','rows')';
end

