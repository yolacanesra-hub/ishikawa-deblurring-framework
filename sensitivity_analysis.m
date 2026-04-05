function sensitivity_analysis_plane()

clc; clear; close all;
rng(0);

%% ================= PATH =================
inputFolder  = 'C:\Users\esray\Desktop\all_images';
outputFolder = 'C:\Users\esray\Desktop\comparison_figures';

imageName   = '06.png';   % Plane
imageLabel  = 'Plane';

imagePath = fullfile(inputFolder, imageName);

if ~exist(imagePath, 'file')
    error('Goruntu bulunamadi: %s', imagePath);
end

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% ================= LOAD IMAGE =================
I = im2double(imread(imagePath));
if size(I,3) == 3
    I = rgb2gray(I);
end
I = mat2gray(I);

%% ================= DEGRADATION =================
PSF = fspecial('motion', 15, 0);
noiseVar = 0.001;

blurred = imfilter(I, PSF, 'circular', 'conv');
noisy   = imnoise(blurred, 'gaussian', 0, noiseVar);

%% ================= FIXED PARAMETERS =================
rho_fixed   = 0.6;
sigma_fixed = 0.3;
tau_data    = 0.8;
tau_reg     = 0.15;
lambda_reg  = 0.01;
maxIter     = 80;

%% ================= RHO ANALYSIS =================
rhoVals  = [0.1 0.2 0.4 0.6 0.8 1.0];
PSNR_rho = zeros(size(rhoVals));
SSIM_rho = zeros(size(rhoVals));

for i = 1:length(rhoVals)
    out = proposed_ishikawa_restore(noisy, PSF, ...
        rhoVals(i), sigma_fixed, tau_data, tau_reg, lambda_reg, maxIter);

    out = min(max(out,0),1);

    PSNR_rho(i) = compute_psnr_manual(out, I);
    SSIM_rho(i) = compute_ssim_safe(out, I);
end

%% ================= SIGMA ANALYSIS =================
sigmaVals  = [0.1 0.2 0.3 0.4 0.5 0.6];
PSNR_sigma = zeros(size(sigmaVals));
SSIM_sigma = zeros(size(sigmaVals));

for i = 1:length(sigmaVals)
    out = proposed_ishikawa_restore(noisy, PSF, ...
        rho_fixed, sigmaVals(i), tau_data, tau_reg, lambda_reg, maxIter);

    out = min(max(out,0),1);

    PSNR_sigma(i) = compute_psnr_manual(out, I);
    SSIM_sigma(i) = compute_ssim_safe(out, I);
end

%% ================= TABLE OUTPUT =================
T_rho = table(rhoVals(:), PSNR_rho(:), SSIM_rho(:), ...
    'VariableNames', {'rho','PSNR','SSIM'});

T_sigma = table(sigmaVals(:), PSNR_sigma(:), SSIM_sigma(:), ...
    'VariableNames', {'sigmaI','PSNR','SSIM'});

disp('=== Sensitivity Analysis for rho ===');
disp(T_rho);

disp('=== Sensitivity Analysis for sigmaI ===');
disp(T_sigma);

writetable(T_rho, fullfile(outputFolder, 'Sensitivity_rho_Plane.xlsx'));
writetable(T_sigma, fullfile(outputFolder, 'Sensitivity_sigmaI_Plane.xlsx'));

%% ================= FIGURE =================
hFig = figure('Color','w','Position',[100 100 1200 500]);

%% ---------- (A) rho ----------
subplot(1,2,1);
[ax1, h1, h2] = plotyy(rhoVals, PSNR_rho, rhoVals, SSIM_rho);

set(h1, 'LineStyle', '-',  'Marker', 'o', 'LineWidth', 1.8, 'MarkerSize', 7);
set(h2, 'LineStyle', '--', 'Marker', 's', 'LineWidth', 1.8, 'MarkerSize', 7);

xlabel('\rho', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel(ax1(1), 'PSNR (dB)', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel(ax1(2), 'SSIM',      'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('(A) Sensitivity to \rho', 'FontSize', 13, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

set(ax1(1), 'FontSize', 11, 'LineWidth', 0.8, 'FontName', 'Times New Roman', 'Color', 'w');
set(ax1(2), 'FontSize', 11, 'LineWidth', 0.8, 'FontName', 'Times New Roman', 'Color', 'none');

ylim(ax1(1), [20 22]);
ylim(ax1(2), [0.54 0.65]);

grid(ax1(1), 'on');
box(ax1(1), 'on');

legend([h1; h2], {'PSNR', 'SSIM'}, ...
    'Location', 'SouthWest', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman');

%% ---------- (B) sigma_I ----------
subplot(1,2,2);
[ax2, h3, h4] = plotyy(sigmaVals, PSNR_sigma, sigmaVals, SSIM_sigma);

set(h3, 'LineStyle', '-',  'Marker', 'o', 'LineWidth', 1.8, 'MarkerSize', 7);
set(h4, 'LineStyle', '--', 'Marker', 's', 'LineWidth', 1.8, 'MarkerSize', 7);

xlabel('\sigma_I', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel(ax2(1), 'PSNR (dB)', 'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
ylabel(ax2(2), 'SSIM',      'FontSize', 12, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
title('(B) Sensitivity to \sigma_I', 'FontSize', 13, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

set(ax2(1), 'FontSize', 11, 'LineWidth', 0.8, 'FontName', 'Times New Roman', 'Color', 'w');
set(ax2(2), 'FontSize', 11, 'LineWidth', 0.8, 'FontName', 'Times New Roman', 'Color', 'none');

ylim(ax2(1), [20 22]);
ylim(ax2(2), [0.54 0.62]);

grid(ax2(1), 'on');
box(ax2(1), 'on');

legend([h3; h4], {'PSNR', 'SSIM'}, ...
    'Location', 'SouthEast', ...
    'FontSize', 10, ...
    'FontName', 'Times New Roman');

%% ================= OVERALL TITLE =================
annotation('textbox', [0 0.92 1 0.06], ...
    'String', ['Sensitivity Analysis on ', imageLabel], ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 14, ...
    'FontWeight', 'bold', ...
    'FontName', 'Times New Roman');

%% ================= SAVE =================
set(hFig, 'PaperPositionMode', 'auto');

savePath = fullfile(outputFolder, 'Figure_3_Sensitivity.png');
print(hFig, savePath, '-dpng', '-r600');

fprintf('\nFigure kaydedildi: %s\n', savePath);

end