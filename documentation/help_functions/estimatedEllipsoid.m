function [Ellipsoid] = estimatedEllipsoid(resolution, sizeDapi,v)
%VIS_ESTIMATES EMBRYO 

% visualize slice by slice
  mind = [1 1 1] .* resolution; maxd = sizeDapi .* resolution;
  nsteps = sizeDapi;
  step = ( maxd - mind ) ./ nsteps;
  [ x, y, z ] = meshgrid( linspace( mind(2) - step(2), maxd(2) + step(2), nsteps(2) ), linspace( mind(1) - step(1), maxd(1) + step(1), nsteps(1) ), linspace( mind(3) - step(3), maxd(3) + step(3), nsteps(3) ) );
  Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
      2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
      2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
  
  
  
  
  
