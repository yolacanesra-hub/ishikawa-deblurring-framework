function out = proposed_ishikawa_restore(b, PSF, rho, sigmaI, tau_data, tau_reg, lambda_reg, maxIter)
% Proposed Ishikawa-type restoration method

x = b;
L = [0 -1 0; -1 4 -1; 0 -1 0];

for k = 1:maxIter
    residual  = imfilter(x, PSF, 'circular', 'conv') - b;
    grad_data = imfilter(residual, rot90(PSF,2), 'circular', 'conv');

    Cx = x - tau_data * grad_data;
    y  = (1-rho) * x + rho * Cx;

    Ly = imfilter(y, L, 'circular', 'conv');

    % Smoothed regularization term
    regTerm = Ly ./ sqrt(Ly.^2 + 1e-6);

    Iy = y - tau_reg * lambda_reg * regTerm;
    x  = (1-sigmaI) * x + sigmaI * Iy;
    x  = min(max(x,0),1);
end

out = x;

end