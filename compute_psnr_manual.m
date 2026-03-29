function val = compute_psnr_manual(A, B)
% Manual PSNR computation for images normalized to [0,1]

A = double(A);
B = double(B);

mse = mean((A(:) - B(:)).^2);

if mse <= eps
    val = Inf;
else
    val = 10 * log10(1 / mse);
end

end