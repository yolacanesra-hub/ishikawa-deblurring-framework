function x = fista_deblur(y, PSF, lambda, step, maxIter)
% FISTA for image deblurring with quadratic smoothness regularization
%
% Inputs:
%   y       : blurred/noisy input image
%   PSF     : blur kernel
%   lambda  : regularization parameter
%   step    : gradient step size
%   maxIter : maximum iteration number
%
% Output:
%   x       : restored image

x = deconvwnr(y, PSF, 0.001);
x = min(max(x,0),1);

z = x;
t = 1;

h = PSF;
hflip = rot90(h,2);

if nargin < 4 || isempty(step)
    step = 1 / (1 + 8*lambda);
end

for k = 1:maxIter

    Hz = imfilter(z, h, 'circular', 'conv');
    grad_data = imfilter(Hz - y, hflip, 'circular', 'conv');

    grad_reg = laplacian_smooth(z);

    grad = grad_data + lambda * grad_reg;

    x_new = z - step * grad;
    x_new = min(max(x_new,0),1);

    t_new = (1 + sqrt(1 + 4*t^2))/2;
    z = x_new + ((t - 1)/t_new) * (x_new - x);

    x = x_new;
    t = t_new;
end

end