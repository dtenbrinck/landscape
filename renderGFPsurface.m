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
function render_surface(surface3D, landmark, resolution)

% flip dimensions to get a more intuitive view
v=flipdim(double(surface3D>0),3);
v2=flipdim(double(landmark>0),3);

% always render to the same figure
h = figure(1);
close(h);
h = figure(1);
set(h,'Position', [0, 0, 1024, 768]);
set(gcf, 'Color', 'w');

hold on; 

% create isosurface patches at zero level set
p = patch( isosurface(v,0) );
p2 = patch( isosurface(v2,0) );

% compute and set normals for the patches
isonormals(v, p)
isonormals(v2, p2)

% render with red color and without edges
set(p, 'FaceColor','r', 'EdgeColor','none','FaceAlpha',1);
set(p2, 'FaceColor','g', 'EdgeColor','none','FaceAlpha',1);

% set aspect ratio
daspect(1./resolution)  

% adjust a view angle for perspective
view(-122,46), axis off, box off, grid off; camproj perspective

% enable phong lightning model
camlight, lighting phong

% force thread to draw
drawnow;

hold off

end
