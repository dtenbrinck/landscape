function [radii, center, v, axis] = initializeEllipsoidParams(X)
    if size( X, 2 ) ~= 3
    error( 'Input data must have three columns!' );
    else
        x = X( :, 1 );
        y = X( :, 2 );
        z = X( :, 3 );
        center=[mean(x); mean(y); mean(z)];
        radii=[max(abs(x - center(1))); max(abs(y - center(2)));max(abs(z - center(3)))]; 
        v=zeros(6,1);
        v(1:3) = (1./radii).^2;
        v(4:6) = - center .* v(1:3);
        axis = eye(3);
    end
end