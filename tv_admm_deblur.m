function rec = tv_admm_deblur(b, PSF, lambda, rho, maxit)
% Improved TV-ADMM deblurring
% b      : blurred/noisy image
% PSF    : blur kernel
% lambda : TV regularization parameter
% rho    : ADMM penalty parameter
% maxit  : number of iterations

[m, n] = size(b);

% PSF -> OTF
H = psf2otf(PSF, [m n]);
HTH = abs(H).^2;

% Finite difference filters
dx = [1 -1];
dy = [1; -1];

Dx = psf2otf(dx, [m n]);
Dy = psf2otf(dy, [m n]);

DTD = abs(Dx).^2 + abs(Dy).^2;

% Initialization
x  = b;
zx = zeros(m,n);
zy = zeros(m,n);
ux = zeros(m,n);
uy = zeros(m,n);

Bhat = fft2(b);

for k = 1:maxit

    % x-update (frequency domain solution)
    rhs = conj(H) .* Bhat + rho * conj(Dx) .* fft2(zx - ux) + rho * conj(Dy) .* fft2(zy - uy);
    x = real(ifft2(rhs ./ (HTH + rho * DTD + 1e-8)));
    x = min(max(x,0),1);

    % Gradient
    [gx, gy] = grad_op(x);

    % z-update (vector soft-thresholding / isotropic TV)
    vx = gx + ux;
    vy = gy + uy;

    mag = sqrt(vx.^2 + vy.^2);
    shrink = max(mag - lambda/rho, 0) ./ max(mag, 1e-12);

    zx = shrink .* vx;
    zy = shrink .* vy;

    % Dual update
    ux = ux + gx - zx;
    uy = uy + gy - zy;
end

rec = min(max(x,0),1);

end