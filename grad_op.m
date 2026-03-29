function [Dx, Dy] = grad_op(x)
Dx = [diff(x,1,2), x(:,1) - x(:,end)];
Dy = [diff(x,1,1); x(1,:) - x(end,:)];
end