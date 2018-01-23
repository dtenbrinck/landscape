function x = newtonIteration( f, Jac, x0, tol_rel)

%     newton iteration to solve f(x) = 0
%     x_n+1 = x_n - inv(J(x_n))*f(x_n)
%     J(x_n) * delta_x_n = -f(x_n)
%     x_n+1 = x_n + delta_x_n

%   input:
%   f = function handle to evaluate f
%   Jac = function handle for Jacobian of f
%   x_0 = start value of iteration
%   tol_rel = relative tolerance of result

%   output:
%   x = approximation of x solving f(x) = 0

x = x0;
error_rel = realmax;

while error_rel > tol_rel
    J = Jac(x);
    rhs = f(x);
  delta_x = J \ rhs;
  error_rel = norm(delta_x) / norm(x);
  x = x + delta_x;
end

end