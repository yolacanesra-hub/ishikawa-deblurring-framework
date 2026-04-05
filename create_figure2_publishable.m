function create_figure2_publishable( ...
    GT_all, Noisy_all, Proposed_all, TV_all, FISTA_all, LR_all, Wiener_all, ...
    PSNR_all, SSIM_all, selectedIdx, rowTags, zoomRects, savePath)
% MATLAB 2016 compatible publishable Figure 2
%
% Layout:
% Top  : Full images
% Mid  : Zoom-in patches
% Bottom: Difference maps
%
% Columns:
% GT | Blurred | Proposed | TV | FISTA | LR | Wiener

colTitles = {'GT', 'Blurred', 'Proposed', 'TV', 'FISTA', 'LR', 'Wiener'};
numRows = length(selectedIdx);
numCols = 7;

hFig = figure('Color','w','Position',[30 30 2100 1350]);

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

    diffMaps = { ...
        zeros(size(GT)), ...
        abs(BLR  - GT), ...
        abs(PROP - GT), ...
        abs(TVI  - GT), ...
        abs(FIS  - GT), ...
        abs(LRI  - GT), ...
        abs(WIE  - GT)};

    % ===================== ROW 1: FULL IMAGES =====================
    for c = 1:numCols
        idx = (r-1)*numCols + c;
        subplot(numRows*3, numCols, idx);

        imshow(imgs{c}, []);
        axis off;

        hold on;
        rectangle('Position', rect, 'EdgeColor', 'y', 'LineWidth', 1.2);
        hold off;

        if r == 1
            title(colTitles{c}, 'FontSize', 12, 'FontWeight', 'bold');
        end

        if c >= 3
            [ps, ss] = get_metric_pair(c, n, PSNR_all, SSIM_all);
            text(5, size(imgs{c},1)-15, ...
                sprintf('PSNR %.2f dB\nSSIM %.3f', ps, ss), ...
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

    % ===================== ROW 2: ZOOM PATCHES =====================
    for c = 1:numCols
        idx = numRows*numCols + (r-1)*numCols + c;
        subplot(numRows*3, numCols, idx);

        patch = crop_patch(imgs{c}, rect);
        imshow(patch, []);
        axis off;

        if c == 1
            ylabel('Zoom', 'FontSize', 11, 'FontWeight', 'bold');
        end
    end

    % ===================== ROW 3: DIFFERENCE MAPS =====================
    for c = 1:numCols
        idx = 2*numRows*numCols + (r-1)*numCols + c;
        subplot(numRows*3, numCols, idx);

        if c == 1
            imshow(zeros(size(GT)), []);
            axis off;
            text(size(GT,2)/2, size(GT,1)/2, 'N/A', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 12, 'FontWeight', 'bold');
        else
            imagesc(diffMaps{c});
            axis image off;
            colormap(gca, gray);
            caxis([0 0.4]);
        end

        if c == 1
            ylabel('Error Map', 'FontSize', 11, 'FontWeight', 'bold');
        end
    end
end

set(hFig, 'PaperPositionMode', 'auto');
print(hFig, savePath, '-dpng', '-r300');
close(hFig);

end

function patch = crop_patch(I, rect)
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

function [ps, ss] = get_metric_pair(c, n, PSNR_all, SSIM_all)
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
        ps = NaN; ss = NaN;
end
end