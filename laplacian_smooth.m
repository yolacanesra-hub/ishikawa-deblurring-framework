function out = laplacian_smooth(x)
% Quadratic smoothness gradient using discrete Laplacian

L = [0 -1 0; -1 4 -1; 0 -1 0];
out = imfilter(x, L, 'circular', 'conv');

end