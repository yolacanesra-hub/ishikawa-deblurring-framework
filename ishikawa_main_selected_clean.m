function ishikawa_main_selected_clean()


clc; clear; close all;
rng(0);

%% ================= PATH =================
inputFolder  = 'C:\Users\esray\Desktop\all_images';
outputFolder = 'C:\Users\esray\Desktop\comparison_figures';

if ~exist(inputFolder, 'dir')
    error('Girdi klasoru bulunamadi: %s', inputFolder);
end

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

%% ================= IMAGE LIST =================
imageFiles = { ...
    '04.png', ...
    '06.png', ...
    '09.png', ...
    '10.png', ...
    '11.png', ...
    '12.png'};

imageLabels = { ...
    'Starfish', ...
    'Plane', ...
    'Woman', ...
    'Boats', ...
    'Pirate', ...
    'Couple'};

numImages = length(imageFiles);

fprintf('Toplam %d goruntu islenecek:\n', numImages);

%% ================= PARAMETERS =================
PSF = fspecial('motion', 15, 0);
noiseVar = 0.001;

rho = 0.6;
sigmaI = 0.3;
tau_data = 0.8;
tau_reg = 0.15;
lambda_reg = 0.01;
maxIter = 80;

% TV icin iyilestirilmis parametreler
tv_lambda = 0.005;
tv_rho    = 1.0;
tv_iter   = 150;

%% ================= RESULT ARRAYS =================
PSNR_all = nan(numImages,5);
SSIM_all = nan(numImages,5);

%% ================= MAIN LOOP =================
for n = 1:numImages

    fname = imageFiles{n};
    fpath = fullfile(inputFolder, fname);

    if ~exist(fpath, 'file')
        fprintf('Eksik dosya: %s\n', fname);
        continue;
    end

    I = im2double(imread(fpath));

    if size(I,3) == 3
        I = rgb2gray(I);
    end

    I = mat2gray(I);

    fprintf('Isleniyor: %s (%s)\n', fname, imageLabels{n});

    %% Degradation
    blurred = imfilter(I, PSF, 'circular', 'conv');
    noisy   = imnoise(blurred, 'gaussian', 0, noiseVar);

    %% Methods
    proposed = proposed_ishikawa_restore(noisy, PSF, ...
        rho, sigmaI, tau_data, tau_reg, lambda_reg, maxIter);

    wiener = deconvwnr(noisy, PSF, noiseVar);
    lr     = deconvlucy(noisy, PSF, 20);
    tv     = tv_admm_deblur(noisy, PSF, tv_lambda, tv_rho, tv_iter);
    fista  = fista_deblur(noisy, PSF, 0.005, 0.8, 300);

    %% Clamp
    proposed = min(max(proposed, 0), 1);
    wiener   = min(max(wiener,   0), 1);
    lr       = min(max(lr,       0), 1);
    tv       = min(max(tv,       0), 1);
    fista    = min(max(fista,    0), 1);

    %% Metrics
    PSNR_all(n,:) = [ ...
        compute_psnr_manual(proposed, I), ...
        compute_psnr_manual(wiener,   I), ...
        compute_psnr_manual(lr,       I), ...
        compute_psnr_manual(tv,       I), ...
        compute_psnr_manual(fista,    I)];

    SSIM_all(n,:) = [ ...
        compute_ssim_safe(proposed, I), ...
        compute_ssim_safe(wiener,   I), ...
        compute_ssim_safe(lr,       I), ...
        compute_ssim_safe(tv,       I), ...
        compute_ssim_safe(fista,    I)];

    %% Figure
    h = figure('Visible','off','Color','w','Position',[50 50 1600 850]);

    subplot(2,4,1);
    imshow(I, []);
    title('Ground Truth');

    subplot(2,4,2);
    imshow(noisy, []);
    title('Blurred + Noisy');

    subplot(2,4,3);
    imshow(proposed, []);
    title(sprintf('Proposed\nPSNR = %.2f dB\nSSIM = %.4f', PSNR_all(n,1), SSIM_all(n,1)));

    subplot(2,4,4);
    imshow(tv, []);
    title(sprintf('TV\nPSNR = %.2f dB\nSSIM = %.4f', PSNR_all(n,4), SSIM_all(n,4)));

    subplot(2,4,5);
    imshow(wiener, []);
    title(sprintf('Wiener\nPSNR = %.2f dB\nSSIM = %.4f', PSNR_all(n,2), SSIM_all(n,2)));

    subplot(2,4,6);
    imshow(lr, []);
    title(sprintf('LR\nPSNR = %.2f dB\nSSIM = %.4f', PSNR_all(n,3), SSIM_all(n,3)));

    subplot(2,4,7);
    imshow(fista, []);
    title(sprintf('FISTA\nPSNR = %.2f dB\nSSIM = %.4f', PSNR_all(n,5), SSIM_all(n,5)));

    subplot(2,4,8);
    axis off;
    text(0.1,0.6,imageLabels{n},'FontSize',16,'FontWeight','bold');

    drawnow;
    set(h, 'PaperPositionMode', 'auto');
    print(h, fullfile(outputFolder, sprintf('Fig_%d_%s_300dpi.png', n, imageLabels{n})), '-dpng', '-r300');
    close(h);
end

%% ================= TABLES =================
validRows = ~isnan(PSNR_all(:,1));

T_PSNR = table( ...
    imageLabels(validRows)', ...
    PSNR_all(validRows,1), ...
    PSNR_all(validRows,2), ...
    PSNR_all(validRows,3), ...
    PSNR_all(validRows,4), ...
    PSNR_all(validRows,5), ...
    'VariableNames', {'Image','Proposed','Wiener','LR','TV','FISTA'});

writetable(T_PSNR, fullfile(outputFolder, 'PSNR_Table.xlsx'));

T_SSIM = table( ...
    imageLabels(validRows)', ...
    SSIM_all(validRows,1), ...
    SSIM_all(validRows,2), ...
    SSIM_all(validRows,3), ...
    SSIM_all(validRows,4), ...
    SSIM_all(validRows,5), ...
    'VariableNames', {'Image','Proposed','Wiener','LR','TV','FISTA'});

writetable(T_SSIM, fullfile(outputFolder, 'SSIM_Table.xlsx'));

%% ================= BAR GRAPHS =================
hBar1 = figure('Color','w');
bar(PSNR_all(validRows, :));
set(gca,'XTick',1:sum(validRows), ...
    'XTickLabel',imageLabels(validRows), ...
    'XTickLabelRotation',45);
legend('Proposed','Wiener','LR','TV','FISTA','Location','best');
title('PSNR Comparison');
ylabel('dB');
grid on;
drawnow;
set(hBar1, 'PaperPositionMode', 'auto');
print(hBar1, fullfile(outputFolder, 'PSNR_BarGraph_300dpi.png'), '-dpng', '-r300');

hBar2 = figure('Color','w');
bar(SSIM_all(validRows, :));
set(gca,'XTick',1:sum(validRows), ...
    'XTickLabel',imageLabels(validRows), ...
    'XTickLabelRotation',45);
legend('Proposed','Wiener','LR','TV','FISTA','Location','best');
title('SSIM Comparison');
ylabel('SSIM');
grid on;
drawnow;
set(hBar2, 'PaperPositionMode', 'auto');
print(hBar2, fullfile(outputFolder, 'SSIM_BarGraph_300dpi.png'), '-dpng', '-r300');

%% ================= IMAGE-WISE SENSITIVITY ANALYSIS =================
rhoVals   = [0.2 0.4 0.6 0.8 1.0];
sigmaVals = [0.1 0.2 0.3 0.4 0.5];

for n = 1:numImages

    fname = imageFiles{n};
    fpath = fullfile(inputFolder, fname);

    if ~exist(fpath, 'file')
        fprintf('Sensitivity icin atlandi: %s\n', fname);
        continue;
    end

    I_sens = im2double(imread(fpath));

    if size(I_sens,3) == 3
        I_sens = rgb2gray(I_sens);
    end

    I_sens = mat2gray(I_sens);

    blurred_sens = imfilter(I_sens, PSF, 'circular', 'conv');
    noisy_sens   = imnoise(blurred_sens, 'gaussian', 0, noiseVar);

    sensPSNR = zeros(length(rhoVals), length(sigmaVals));
    sensSSIM = zeros(length(rhoVals), length(sigmaVals));

    for i = 1:length(rhoVals)
        for j = 1:length(sigmaVals)

            out = proposed_ishikawa_restore(noisy_sens, PSF, ...
                rhoVals(i), sigmaVals(j), tau_data, tau_reg, lambda_reg, maxIter);

            out = min(max(out,0),1);

            sensPSNR(i,j) = compute_psnr_manual(out, I_sens);
            sensSSIM(i,j) = compute_ssim_safe(out, I_sens);
        end
    end

    rowNames = cell(length(rhoVals),1);
    for i = 1:length(rhoVals)
        rowNames{i} = sprintf('rho_%d', round(rhoVals(i)*10));
    end

    colNames = cell(1,length(sigmaVals));
    for j = 1:length(sigmaVals)
        colNames{j} = sprintf('sigma_%d', round(sigmaVals(j)*10));
    end

    T_psnr = array2table(sensPSNR, 'VariableNames', colNames, 'RowNames', rowNames);
    T_ssim = array2table(sensSSIM, 'VariableNames', colNames, 'RowNames', rowNames);

    label = imageLabels{n};

    writetable(T_psnr, fullfile(outputFolder, sprintf('Sensitivity_PSNR_%s.xlsx', label)), ...
        'WriteRowNames', true);
    writetable(T_ssim, fullfile(outputFolder, sprintf('Sensitivity_SSIM_%s.xlsx', label)), ...
        'WriteRowNames', true);

    % Temsili grafik sadece Plane icin
    if strcmpi(fname, '06.png')

        [SIG, RHO] = meshgrid(sigmaVals, rhoVals);

        hSens1 = figure('Color','w');
        surf(SIG, RHO, sensPSNR);
        xlabel('\sigma_I');
        ylabel('\rho');
        zlabel('PSNR (dB)');
        title('Sensitivity Analysis on Plane (PSNR)');
        shading interp;
        grid on;
        view(135,30);
        drawnow;
        set(hSens1, 'PaperPositionMode', 'auto');
        print(hSens1, fullfile(outputFolder, 'Sensitivity_PSNR_Plane_300dpi.png'), '-dpng', '-r300');
        close(hSens1);

        hSens2 = figure('Color','w');
        surf(SIG, RHO, sensSSIM);
        xlabel('\sigma_I');
        ylabel('\rho');
        zlabel('SSIM');
        title('Sensitivity Analysis on Plane (SSIM)');
        shading interp;
        grid on;
        view(135,30);
        drawnow;
        set(hSens2, 'PaperPositionMode', 'auto');
        print(hSens2, fullfile(outputFolder, 'Sensitivity_SSIM_Plane_300dpi.png'), '-dpng', '-r300');
        close(hSens2);
    end
end

fprintf('\nImage-wise sensitivity analysis tamamlandi.\n');
fprintf('\nTum islemler tamamlandi.\n');
fprintf('Cikti klasoru: %s\n', outputFolder);

end