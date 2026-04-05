function sensitivity_analysis_appendix()

clc; clear; close all;
rng(0);

inputFolder  = 'C:\Users\esray\Desktop\all_images';
outputFolder = 'C:\Users\esray\Desktop\comparison_figures';

imageFiles  = {'04.png','10.png'}; % Starfish, Boats
imageLabels = {'Starfish','Boats'};

PSF = fspecial('motion', 15, 0);
noiseVar = 0.001;

rhoVals   = [0.1 0.2 0.4 0.6 0.8 1.0];
sigmaVals = [0.1 0.2 0.3 0.4 0.5 0.6];

tau_data   = 0.8;
tau_reg    = 0.15;
lambda_reg = 0.01;
maxIter    = 80;

rho_fixed   = 0.6;
sigma_fixed = 0.3;

hFig = figure('Color','w','Position',[100 100 1400 700]);

plotIdx = 1;

for n = 1:2

    % Load
    I = im2double(imread(fullfile(inputFolder, imageFiles{n})));
    if size(I,3)==3, I = rgb2gray(I); end
    I = mat2gray(I);

    % Degrade
    blurred = imfilter(I, PSF, 'circular', 'conv');
    noisy   = imnoise(blurred, 'gaussian', 0, noiseVar);

    %% ---- RHO ----
    PSNR_rho = zeros(size(rhoVals));
    SSIM_rho = zeros(size(rhoVals));

    for i=1:length(rhoVals)
        out = proposed_ishikawa_restore(noisy, PSF, ...
            rhoVals(i), sigma_fixed, tau_data, tau_reg, lambda_reg, maxIter);

        PSNR_rho(i) = compute_psnr_manual(out, I);
        SSIM_rho(i) = compute_ssim_safe(out, I);
    end

    subplot(2,2,plotIdx); plotIdx = plotIdx + 1;
    [ax,h1,h2] = plotyy(rhoVals, PSNR_rho, rhoVals, SSIM_rho);

    set(h1,'LineWidth',1.5,'Marker','o');
    set(h2,'LineWidth',1.5,'Marker','s','LineStyle','--');

    title([imageLabels{n}, ' - \rho']);
    xlabel('\rho'); grid on;

    %% ---- SIGMA ----
    PSNR_sigma = zeros(size(sigmaVals));
    SSIM_sigma = zeros(size(sigmaVals));

    for i=1:length(sigmaVals)
        out = proposed_ishikawa_restore(noisy, PSF, ...
            rho_fixed, sigmaVals(i), tau_data, tau_reg, lambda_reg, maxIter);

        PSNR_sigma(i) = compute_psnr_manual(out, I);
        SSIM_sigma(i) = compute_ssim_safe(out, I);
    end

    subplot(2,2,plotIdx); plotIdx = plotIdx + 1;
    [ax,h1,h2] = plotyy(sigmaVals, PSNR_sigma, sigmaVals, SSIM_sigma);

    set(h1,'LineWidth',1.5,'Marker','o');
    set(h2,'LineWidth',1.5,'Marker','s','LineStyle','--');

    title([imageLabels{n}, ' - \sigma_I']);
    xlabel('\sigma_I'); grid on;

end

set(hFig,'PaperPositionMode','auto');
print(hFig, fullfile(outputFolder,'Appendix_Sensitivity.png'), '-dpng','-r300');

end