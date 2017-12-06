function visualizeEmbryoFitting(DAPI_data,resolution,ellipsoid)

[x,y,z] = meshgrid(1:size(DAPI_data,2),1:size(DAPI_data,1),1:size(DAPI_data,3));
x = resolution(1) * x;
y = resolution(2) * y;
z = resolution(3) * z;

v = ellipsoid.v;

levelsets = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
    2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
    2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;

figure; slideShow(DAPI_data,levelsets > 1, './results/gifs/');

end

