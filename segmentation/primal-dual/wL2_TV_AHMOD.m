function [u, rel_change] = wL2_TV_AHMOD(dataP, algP, q, h, nonneg)
% wL2_TV_AHMOD minimizes a "weighted version of the ROF model" of the form
%
%   min_{u in C} 1/2 * int_Omega (u - q)^2 / h dx + alpha * TV(u)
%
% using accelerated modified Arrow-Hurwicz primal-dual algorithm proposed in
% (Chambolle, Pock, First-Order Primal-Dual Algorithm for Convex Problems with
% Applications to Imaging, J. Math. Imaging Vis. (2011)), where TV is the total
% variation energy defined formally by
%
%   TV(u) = int_Omega |gradient(u)| dx , |.| is l1 or l2 vector norm ,
%
% and C an additional constraint condition of the form
%
%   C = {u : u(x) >= 0 for all x in Omega}  or  C = {u : u(x) in (-infty,+infty) for all x in Omega}.
%
% @param
%   dataP - structure array containing parameters with respect to the given
%           data such as number of pixels, image dimension etc.
%   algP  - structure array containing parameters which are required to
%           perform the algorithm, namely
%   q     - "noisy" function
%   h     - weight function in the data fidelity term
%   nonneg - binary value (1 if non-negativity should be forced, and 0 or [] else)
%
% @return
%   approx - minimizer of "weighted version of ROF model"
%   stat - structure array containing statistics of interested such as run
%          time, convergence rate etc.
%
% Copyright Oct 2013 Alex Sawatzky
% Institute for Computational and Applied Mathematics
% University of Muenster
% email: alex.sawatzky@wwu.de
% www: wwwmath.uni-muenster.de/u/sawatzky/
%
% Modified by Daniel Tenbrinck, 2016/01/04

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% initialize necessary parameters

% interval to give information about segmentation process
if isfield(algP,'showInterval')
  showInterval = algP.showInterval;
else
  showInterval = 20;
end

% show segmentation results
if isfield(algP,'showSegmentation')
  showSegmentation = algP.showSegmentation;
else
  showInterval = true;
end

% plot relative errors
if isfield(algP,'plotError')
  plotError = algP.plotError;
else
  plotError = true;
end

% check for nonnegativity constraint
if isempty(nonneg)
  nonneg = 0;
end

% effective regularization parameter
alpha = algP.alpha;

% stopping value
stop = algP.regAccur + 1;

% number of iterations
nrTVIts = 0;

% initialize iteration variables
g = zeros(dataP.nx,dataP.ny,dataP.nz,dataP.dim);
u = q;

% positive step sizes, see (Chambolle, Pock, First-Order Primal-Dual Algorithm
% for Convex Problems with Applications to Imaging, J. Math. Imaging Vis. (2011))
hXYZ = [dataP.hx dataP.hy dataP.hz];
hXYZ = hXYZ(hXYZ ~= 0);

if isfield(algP,'tau')
  tau = algP.tau;
else
  tau = 0.02;
end

sigma = 4 / ((4 * sum(hXYZ.^(-2))) * tau) ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% define functions depending on chosen TV formulation
if isfield(algP,'TV') && strcmp(algP.TV,'aniso')
  absdualvar = @(dualvar) max(abs(dualvar),[],4);
else% use isotropic TV formulation
  algP.TV = 'iso';
  absdualvar = @(dualvar) sqrt(sum(dualvar.^2,4));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% define projection into admissible solution set
proj_admissible_set = @(arg) arg;
if nonneg
  proj_admissible_set = @(arg) max(arg,1e-8);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TV (augmented Lagrangian approach) denoising
fprintf('\nPerform wL2_TV_AHMOD denoising (TV: %s, alpha: %g, maxIt: %i, regAccur: %g) ...\n', algP.TV, alpha, algP.maxIts, algP.regAccur);
tic;
u_old = u;
rel_change = zeros(1, algP.maxIts);
while (nrTVIts < algP.maxIts) && ...
    ( isempty(algP.regAccur) || ...
    ( ~isempty(algP.regAccur) && stop >= algP.regAccur ) )
  
  
  % minimization wrt dual variable g
  arg = g + sigma * grad(u, dataP);
  tv = absdualvar(arg);
  g = arg ./ max(1,repmat(tv,[1 1 1 dataP.dim]));
  
  % minimization wrt primal variable u
  divergence = div(g, dataP);
  u = proj_admissible_set( (alpha * h .* (u + tau * divergence) + tau * q) ./ (alpha * h + tau) );
  
  % update step sizes
  %eta = 1 / sqrt(1 + 2 * 0.7 * (alpha * max(h(:))) ^(-1) * tau);
  eta = 1 / sqrt(1 + 2 * 0.35 * (alpha * max(h(:))) ^(-1) * tau);
  tau = eta * tau;
  sigma = sigma / eta;
  
  % update step counter
  nrTVIts = nrTVIts + 1;
  
  % compute relative change
  rel_change(nrTVIts) = norm(u(:)-u_old(:)) / norm(u_old(:));
  
  if mod(nrTVIts,showInterval) == 0
    
    % show current parameters and relative error
    fprintf('    ItStep: %i (Rel.Error: %g, tau: %g, sigma: %g)\n', nrTVIts, rel_change(nrTVIts), tau, sigma);
    
    % draw current segmentation contour
    if showSegmentation == true
      
      % compute characteristic function
      Xi = zeros(size(u));
      Xi(u >= dataP.t+1) = 1;
      
      % visualize according to dimensionality of data
      if ndims(dataP.f) == 2
        drawSegmentation(dataP.f, Xi);
      elseif ndims(dataP.f) == 3
        renderSurface(Xi);
      end
      
    end
    
    % plot relative error descent
    if plotError == true
      figure(2); plot(rel_change(1:nrTVIts));
    end
    
  end
  
  % update old iteration variable
  u_old = u;
  
end

% measure time
fprintf('wL2_TV_AHMOD denoising finished in %i steps after %g seconds with a relative error of %g!\n\n', nrTVIts, toc, rel_change(nrTVIts));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% nested functions

end
