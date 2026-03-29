function val = compute_ssim_safe(A, B)
% Safe SSIM computation
% Uses built-in ssim if available; otherwise uses a simple fallback formula.

A = double(A);
B = double(B);

if exist('ssim', 'file') == 2
    val = ssim(A, B);
    return;
end

K1 = 0.01;
K2 = 0.03;
L = 1;

C1 = (K1 * L)^2;
C2 = (K2 * L)^2;

muA = mean(A(:));
muB = mean(B(:));

varA = var(A(:), 1);
varB = var(B(:), 1);
covAB = mean((A(:) - muA) .* (B(:) - muB));

val = ((2 * muA * muB + C1) * (2 * covAB + C2)) / ...
      ((muA^2 + muB^2 + C1) * (varA + varB + C2));

end