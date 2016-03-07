%DRAW_SEGMENTATION Renders current 3D segmentation surface.
%   RENDER_SURFACE(PHI) renders the current 3D segmentation surface
%   induced by the zero level set of a function PHI.
%
%
%   Copyright: Alex Sawatzky, Daniel Tenbrinck 
%   Department of Mathematics and Computer Science
%   University of Muenster, Germany
%   email: alex.sawatzky@wwu.de - daniel.tenbrinck@wwu.de
%   $Date: 2013/12/17 $
%
%   IMPORTANT: When using this code please cite the following publication.
%   Sawatzky A, Tenbrinck D, Jiang X, Burger M, "A Variational Framework for 
%   Region-Based Segmentation Incorporating Physical Noise Models", Journal 
%   of Mathematical Imaging and Vision 47(3), p. 179-209 (2013)
function renderGFPsurface(surface3D, landmark, resolution, x, y, z)

  surface3D = flipdim(double(surface3D),3);
  landmark = flipdim(double(landmark),3);

  %test = (surface3D) .* landmark;
  %slideShow(test);
  
  figure;
  p = patch( isosurface( x, y, z, surface3D, 0 ) );
  hold on
  %p2 = patch( isosurface( x, y, z, landmark .* (surface3D + 1) .* (surface3D <= 0.05), 1)); 
  p2 = patch( isosurface( x, y, z, landmark .* (surface3D + 1), 1)); 
  set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
  set( p2, 'FaceColor', 'r', 'EdgeColor', 'none' );
  %view( -70, 40 );
  hold off
  axis vis3d equal;
  daspect(resolution(3)./resolution)
  camlight;
  
  figure; 
   p = patch( isosurface( x, y, z, surface3D, 0 ) );
  hold on
  %p2 = patch( isosurface( x, y, z, landmark .* (surface3D + 1) .* (surface3D <= 0.05), 1)); 
  p2 = patch( isosurface( x, y, z, landmark, 0.5)); 
  set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
  set( p2, 'FaceColor', 'r', 'EdgeColor', 'none' );
  %view( -70, 40 );
  hold off
  axis vis3d equal;
  daspect(resolution(3)./resolution)
  camlight;
  %lighting phong;

end
