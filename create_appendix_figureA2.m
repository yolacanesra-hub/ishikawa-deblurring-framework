function create_appendix_figureA2( ...
    GT_all, Noisy_all, Proposed_all, TV_all, FISTA_all, LR_all, Wiener_all, ...
    PSNR_all, SSIM_all, selectedIdx, rowTags, zoomRects, savePath)
% MATLAB 2016 compatible
% Appendix Figure A2:
% Full images + zoom patches for remaining test images
%
% Column order:
% GT | Blurred | Proposed | TV | FISTA | LR | Wiener

colTitles = {'GT', 'Blurred', 'Proposed', 'TV', 'FISTA', 'LR', 'Wiener'};
numRows = length(selectedIdx);
numCols = 7;

hFig = figure('Color','w','Position',[50 50 2100 950]);

for r = 1:numRows
    n = selectedIdx(r);
    rect = zoomRects{r};

    GT   = GT_all{n};
    BLR  = Noisy_all{n};
    PROP = Proposed_all{n};
    TVI  = TV_all{n};
    FIS  = FISTA_all{n};
    LRI  = LR_all{n};
    WIE  = Wiener_all{n};

    imgs = {GT, BLR, PROP, TVI, FIS, LRI, WIE};

    %% ===================== ROW 1: FULL IMAGES =====================
    for c = 1:numCols
        subplot(numRows*2, numCols, (r-1)*numCols + c);

        imshow(imgs{c}, []);
        axis off;

        hold on;
        rectangle('Position', rect, 'EdgeColor', 'y', 'LineWidth', 1.2);
        hold off;

        if r == 1
            title(colTitles{c}, 'FontSize', 12, 'FontWeight', 'bold');
        end

        % Metrics only for restored results
        if c >= 3
            [ps, ss] = get_metric_pair_A2(c, n, PSNR_all, SSIM_all);

            text(5, size(imgs{c},1)-15, ...
                sprintf('%.2f dB | %.3f', ps, ss), ...
                'Color', 'w', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                'BackgroundColor', 'k', ...
                'Margin', 2, ...
                'VerticalAlignment', 'bottom');
        end

        if c == 1
            text(-35, size(imgs{c},1)/2, rowTags{r}, ...
                'Rotation', 90, ...
                'FontSize', 12, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
        end
    end

    %% ===================== ROW 2: ZOOM PATCHES =====================
    for c = 1:numCols
        subplot(numRows*2, numCols, numRows*numCols + (r-1)*numCols + c);

        patch = crop_patch_A2(imgs{c}, rect);
        imshow(patch, []);
        axis off;

        if c == 1
            text(-20, size(patch,1)/2, 'Zoom', ...
                'Rotation', 90, ...
                'FontSize', 11, ...
                'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
        end
    end
end

annotation('textbox', [0 0.955 1 0.04], ...
    'String', 'Appendix Fig. A2. Additional qualitative comparisons for the remaining test images.', ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'FontSize', 13, ...
    'FontWeight', 'bold');

set(hFig, 'PaperPositionMode', 'auto');
print(hFig, savePath, '-dpng', '-r300');
close(hFig);

end

%% ============================================================
function patch = crop_patch_A2(I, rect)
x = round(rect(1));
y = round(rect(2));
w = round(rect(3));
h = round(rect(4));

[H, W] = size(I);

x1 = max(1, x);
y1 = max(1, y);
x2 = min(W, x + w - 1);
y2 = min(H, y + h - 1);

patch = I(y1:y2, x1:x2);
end

%% ============================================================
function [ps, ss] = get_metric_pair_A2(c, n, PSNR_all, SSIM_all)
% Columns:
% 1 GT
% 2 Blurred
% 3 Proposed
% 4 TV
% 5 FISTA
% 6 LR
% 7 Wiener

switch c
    case 3
        ps = PSNR_all(n,1); ss = SSIM_all(n,1); % Proposed
    case 4
        ps = PSNR_all(n,4); ss = SSIM_all(n,4); % TV
    case 5
        ps = PSNR_all(n,5); ss = SSIM_all(n,5); % FISTA
    case 6
        ps = PSNR_all(n,3); ss = SSIM_all(n,3); % LR
    case 7
        ps = PSNR_all(n,2); ss = SSIM_all(n,2); % Wiener
    otherwise
        ps = NaN;
        ss = NaN;
end
end